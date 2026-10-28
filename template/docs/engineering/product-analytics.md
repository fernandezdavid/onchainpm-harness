# Product analytics

How to set up analytics so it answers the product's questions and carries no user content. The examples use PostHog, but the rules apply to any tool.

## Three sinks, three questions

| Sink | Answers | Example |
| --- | --- | --- |
| Error tracker | Did the software break? | Sentry |
| Performance telemetry | Is it fast, and for which build? | Expo Observe, web vitals |
| Product analytics | What did people do? | PostHog |

Keep them apart. Crashes group worse in an analytics tool, they use up its event budget, and a table that mixes errors, timings and behaviour is hard to query for any of the three.

## Start from the questions

Write the questions first, then the events. A list of events that no question needs gives a dashboard of empty charts. For each question, write down:

| Question | Event(s) | Whose identity | Insight |
| --- | --- | --- | --- |
| Of the visitors to the site, how many start onboarding? | `page_view`, `onboarding_started` | anonymous visitor | funnel, 1-day window |
| Where do they drop off? | one event per step, with a `step_name` | anonymous visitor | funnel, or a breakdown by step |
| How many verify an email and sign in? | `email_verified`, `signed_in` | lead, then account | funnel, window as long as the real gap (days) |
| How many reach the first core action? | `core_action_completed` | account | funnel |
| How many come back at the product's natural cadence? | `core_action_completed` | account | retention and lifecycle, at that cadence |

The "whose identity" column is the one most often missed. A funnel works only where one identity covers every step. Where the identity changes (an anonymous visitor becomes a lead, a lead becomes an account), design the join before you build the dashboard. See "Identity" below.

Pick the retention interval from how people use the product. A training app is weekly: daily is unrealistic, and a person who skips a week is not lost. Use a lifecycle chart (new, returning, resurrecting, dormant) next to the retention table. It shows the people who come back every second week, which a retention table hides.

## The privacy contract

The product's own screens are often the sensitive data: health readings, notes, names, email addresses. Product questions can be answered from the shape of an action alone: a count, a duration, a closed set of values.

1. **Properties pass an allowlist, not a sanitizer.** An unlisted key is dropped, not cleaned. A sanitizer has to be right for every new field. An allowlist has to be right once.
2. **Values are checked too.** A campaign tag is whatever the link said. Drop a string value that looks like an email, a URL or a formatted phone number, even under an allowed key.
3. **Never send error text.** Send a closed set of codes (`timeout`, `network`, `invalid_output`, `other`). An exception message can quote a request, a response or model output, and model output can repeat a user's notes.
4. **Identity is an opaque UUID or nothing.** Refuse anything else; do not clean it. If a caller passes an email where an ID belongs, the right result is no identity. "Who is this" is answered from your own database.
5. **The server takes only attribution keys from a request body.** A status, a reason or a step from a public request is the server's to decide. Write server-derived fields last, so the client cannot overwrite them.

Write a test for each guard, and check that the test fails when you remove the guard. A test that passes without its guard is worse than none.

## What the SDK adds

The properties you pass are not all that leaves the browser. A web SDK adds the page URL, the referrer, and campaign and search parameters that it copies from both (`utm_*`, ad click IDs, search keywords). New SDK versions add more.

- **Put an allowlist in the SDK's pre-send hook** (`before_send` in PostHog). Keep the SDK's own `$` keys, your own keys, safe `utm_*` values and the envelope (`token`, `distinct_id`). Drop every other key. A blocklist of known keys was tried and missed keys twice.
- **Cut every URL to origin and path.** Links that carry a token in the query or the fragment (a magic link, a share link, a saved-session link) otherwise send that token with every event. Cut any value that parses as an `http(s)` URL, not only the keys named today.
- **Cut referrers to their origin.** A referring page's path can carry a token or an email.
- **If the hook throws, drop the event.** Never send an event that the hook did not finish.

## The website: cookieless

An analytics cookie or a persistent identifier on the device needs consent in the EU (ePrivacy). A cookieless mode keeps nothing on the device, which is the basis for running without a consent banner. Whether that is enough is a legal position, so record it as one.

- Set every optional collector off in code: session replay, surveys, heatmaps, autocapture, dead clicks, web vitals, exception capture. An unset flag follows the project's remote settings, so a switch in the vendor's UI can turn one on without a commit. Also refuse to load optional code chunks if the SDK allows it.
- Cookieless counting needs a project setting on the vendor's side (PostHog: "Cookieless server hash mode"). Without it, the vendor drops the events at ingestion, and the browser still shows them as sent.
- Load the tag only on the production host. Local development and preview deploys send nothing.
- **Find out what the cookieless ID covers, on the live project.** In PostHog the hash uses the root domain and a salt that changes daily. So one device is one visitor across `example.com` and `app.example.com` for one day, and a different visitor the next day. A per-visitor funnel across subdomains works with a one-day window and not with a longer one. This was first written from the docs as "per hostname", which was wrong.
- When you move off a tool that set cookies, remove its leftover cookies on load. Otherwise "nothing on the device" is false for every earlier visitor.
- When the analytics script changes, check that every page loads the new version. A cache-busting stamp that only some pages carry leaves most traffic on the old script.

## Identity across the funnel

A typical funnel crosses three identities: an anonymous visitor, a lead (an email that the server knows, before an account exists), and an account.

- **Visitor to lead.** A cookieless browser has no ID to share with the server. Fire browser events up to the step where the visitor becomes a lead (for example: form shown, code requested, code confirmed). From there, the server's events carry the lead's ID. The two compare by day, not per person.
- **Lead to account.** At sign-in, send one alias event from the server that merges the lead's ID into the account's ID. Use the ID the app identifies with, so that one person runs from the first lead event to retention. Send the lead's last event before the alias.
- **Keep the merge alive past the response.** A lead converts once. If the merge request dies with the serverless invocation, the next sign-in cannot repair it. Use the platform's `waitUntil`, or await it with a timeout.
- **Process person profiles only where you need them.** Server events about a lead can skip person processing. The merge is the event that needs it.
- **Verify the merge on one real record** after the first deploy. Open the account's person and check that the lead's events appear there. Until then, treat any funnel that crosses the join as unverified.

## Server events

- Send fire-and-forget on request paths, with a timeout of about 2 seconds, so analytics never delays a user.
- Await on background jobs and crons, so the worker stays alive until the event is sent.
- With no token configured, send nothing. That is the correct state for local development and CI.
- Never throw. A failing analytics call must not fail the request it describes.

## The dashboard

- One dashboard, pinned, set as the project's home page. Name each insight as the question it answers, and say in its description what it cannot show.
- Match each funnel window to the real gap between the steps. Email verification to sign-in can take days. Same-visit steps fit in one day.
- Say what is not in the tool: crashes in the error tracker, speed in the performance telemetry, and any surface that does not report.

## After the first deploy

1. Open the live site once. Check that events arrive with the expected properties and nothing else. Ingestion can take a few minutes.
2. Check that no cookie and no analytics storage key is left on the device.
3. Sign in one real lead, and check the identity merge.
4. Pull the last N events with a read key. Confirm that every identity is a UUID or a cookieless ID, and that no property value looks like content.

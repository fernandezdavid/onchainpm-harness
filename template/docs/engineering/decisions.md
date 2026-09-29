# Engineering decisions

A short record of choices that the code does not explain by itself. Each entry states the decision, the reason, the alternatives we rejected, and where to look before you change it.

This file has two parts:

- **Harness defaults, `H-1` to `H-11`.** Earlier projects paid for these with incidents. They have their own IDs so they never clash with this project's numbers. To change one, write a project ADR that says `Supersedes H-n` and why. Do not edit or delete the default.
- **Project decisions, `H-1` onward.** This project's own decisions, numbered from 1.

## Format

```
## ADR-N: <the decision, as a sentence>

**Decision**: what we do, concretely.
**Why**: the incident or constraint that forced it.
**Alternatives considered**: each one, and why we rejected it.
**Where to look**: files, tests, checks.
```

Rules for entries:

- Write the title as the decision, not the topic. "Migrations are clean-slate" is a decision. "Migration strategy" is not.
- When a value changes what users get (a threshold, a multiplier, a limit), give the source: a citation, or the label "heuristic, refine with data" (H-11).
- When the decision claims an invariant that grep can see, add a check under `tools/adr-verify/checks/` (H-2).
- Take the next free number. When two open branches claim the same number, the second one to merge renumbers.

---

# Harness defaults

---

## H-1: Agent memory is one shared file, layered, and on a budget

**Decision**: `AGENTS.md` is the only source of project rules for every agent. `CLAUDE.md` imports it and adds Claude-only notes. Area rules go in a nested `AGENTS.md` beside the code. Line budgets (root 150, root `CLAUDE.md` 40, nested 100) are enforced by `scripts/check-agent-memory.sh` in CI.

**Why**: agent memory that grows without a limit stops being read. Rules in one tool's private file (a `.cursorrules`, Claude auto-memory) are invisible to the other agents and to teammates. The same correction then has to be given again in every tool.

**Alternatives considered**:
- One file per agent: rejected, because the files drift apart.
- No budget: rejected, because root memory grew until the important rules were lost in it.

**Where to look**: `AGENTS.md` § Memory Budget, `scripts/check-agent-memory.sh`.

---

## H-2: An ADR that claims an invariant carries a drift check

**Decision**: when an ADR says "X only happens in Y" or "A runs before B", a small bash script under `tools/adr-verify/checks/` asserts it with grep. The runner executes all checks in CI on PRs that touch the code or the ADRs, and once a day.

**Why**: the most expensive bugs were an ADR saying one thing while the code did another. Nobody rereads every ADR before a change. A check that fails in CI does.

**Alternatives considered**:
- Code review only: rejected, because reviewers do not remember every ADR.
- Full static analysis: rejected as too slow and too costly to write. Grep on a stable, load-bearing string is enough.

**Where to look**: `tools/adr-verify/README.md`, `.github/workflows/adr-drift-check.yml`.

---

## H-3: Short-lived work lives in the tracker; lasting knowledge lives in markdown

**Decision**: features, bugs and proposals are tracker issues. Strategy, specs, ADRs and runbooks are markdown in this repository. No markdown backlog.

**Why**: a markdown backlog drifted from reality within weeks, and agents kept updating it instead of the tracker. Specs in the tracker disappeared when their issue closed.

**Alternatives considered**: everything in the tracker, or everything in markdown. Both were tried. Both lost information.

**Where to look**: `WAYS_OF_WORKING.md`.

---

## H-4: Feedback PRs carry the verbatim quote and a plain-language proposed solution

**Decision**:
1. A PR or issue that addresses user feedback includes the user's words as a verbatim blockquote, with the source and date. Redact personal data. A paraphrase alone is not enough.
2. Every PR that changes behavior has a **Proposed solution** section: what was wrong, what we chose, and the trade-offs, so that a reviewer understands the fix without reading the diff.

**Why**: paraphrases drift from what the user needed. Outcome-only summaries make reviewers reverse-engineer the intent from the code.

**Alternatives considered**: link to the feedback record only. Rejected, because the link rots and nobody clicks it during review.

**Where to look**: `.github/pull_request_template.md`, `.cursor/rules/feedback-quotes.mdc`.

---

## H-5: Migrations are clean-slate, not legacy-tolerant

**Decision**: a migration maps what maps cleanly and drops the rest by a written, deterministic policy, with a log of what it skipped. It never queues ambiguous rows for a human to review. Data that people curated by hand (reference data, written content) is the exception and is preserved or reseeded with care. Each migration that writes several tables runs in one transaction.

**Why**: at small scale the value of an ambiguous old row is lower than the review time it costs. A deterministic policy plus a skip log is enough audit trail.

**Alternatives considered**:
- Dual-write during a soak window: rejected, because it doubles every write path for no real safety at small scale.
- A review queue for ambiguous rows: rejected, because it turns the owner into a data moderator.

**Where to look**: the migration runbook, when there is one.

---

## H-6: Canonical components over one-off classes, enforced by a ratchet

**Decision**: UI is built from the design system's canonical components. A new visual need adds a modifier to a component; it does not fork a one-off class for one screen. A ratchet test counts one-off classes per component family and fails CI when a count goes up. Consolidation lowers the ceilings.

**Why**: a well-specified component library reached only 50% adoption, because written guidelines do not hold on their own. The ratchet turns "do not fork" into a CI failure.

**Alternatives considered**:
- Guideline only: rejected. That is the state that drifted.
- An exact allowlist of names: rejected for a first version, because every rename churns it.

**Where to look**: add the ratchet test when the component library exists.

---

## H-7: A surface never renders nothing, and a failure is never silent

**Decision**: every surface resolves to one of four states: data, loading, empty, or error. A blank render is not a state. The error branch is checked before the empty branch, so "could not load" never shows as "you have none". Every chart and table has an empty state. Client failures report to the error tracker (H-8).

**Why**: users hit blank screens that nobody could diagnose, because nothing reported client failures. A blank screen looks like a hang, offers nothing to retry, and produces no signal. A failed request once told users with an active plan that they had none.

**Alternatives considered**: start entrance animations fully visible to avoid blank frames. Rejected, because it removes the motion to fix a failure mode. A deadline that forces the final state keeps both.

**Where to look**: the screen error boundary and the error reporting module, when they exist.

---

## H-8: Three telemetry sinks, each with one job; no session replay

**Decision**:
- **Errors** go to an error tracker (for example Sentry). Strip request bodies, query strings, credentials and user identity before an event leaves the process.
- **Behaviour** (funnels, retention, feature adoption) goes to a product analytics tool (for example PostHog). Event properties pass a strict allowlist. Identity is an opaque account UUID, never an email.
- **Operations** (timings, cron health) go to their own place (H-9).
- Session replay is off until there is a written privacy decision.

**Why**: one tool for all three makes each question harder to answer. An allowlist has to be right once; a sanitizer has to be right every time someone adds a field, and its failure mode is a leak. A first-party error collector cannot report its own outage.

**Alternatives considered**: the analytics tool for errors too (rejected: worse grouping), anonymous device IDs (rejected: reinstalls look like new users), email as the identity (rejected: puts personal data in a third processor).

**Where to look**: the analytics and observability modules, when they exist.

---

## H-9: Every scheduled job leaves a pulse and reports before it answers

**Decision**: every scheduled job writes one run record: `running` before the work, then `ok` or `failed`. A registry lists each job with its schedule and how stale it may get, and a test pins the registry to the scheduler config. A health view turns records into one verdict per job: ok, failing, stale, hung, never, missing. A scheduled job awaits its error report before it returns its failure response. Run records carry counts, never names or emails.

**Why**: a daily job failed every morning for weeks and nobody knew. A job with nothing to do and a job that never ran leave the same trace: none. The scheduler's own page shows invocations, not outcomes.

**Alternatives considered**: rely on the hosting platform's cron page. Rejected, because a handler that catches, logs and returns 500 shows as "ran" there.

**Where to look**: add the heartbeat with the first scheduled job.

---

## H-10: Tagged release train; merge pace is not ship pace

**Decision**: `main` is a fast integration line. A release folds `CHANGELOG.md` `[Unreleased]` into a dated section, gets an annotated tag and a release with those notes, and ships that exact commit. Every ship gets a tag, hotfixes included. Ship when there is something worth shipping, not on a calendar. No long-lived release branches.

**Why**: when something breaks in the field, you need to know exactly what is on the user's device. A tag history with gaps is worse than none, because people will trust it.

**Alternatives considered**:
- Deploy on every merge: rejected for user-installed apps, because it removes the moment where device testing happens. Acceptable for a web app with preview deploys; record that choice in an ADR.
- A fixed weekly cadence: rejected at small scale as ceremony.

**Where to look**: `CHANGELOG.md`, the release workflow when it exists.

---

## H-11: Values that change user outcomes carry a source

**Decision**: every value that changes what a user gets (a threshold, a multiplier, a cut, a limit) is recorded with three things: the value, the reason for it over the alternatives, and the source. The source is a checked citation, or the explicit label "heuristic, refine with data".

**Why**: users ask "why this number". "The engine says so" is not an answer, and an unlabeled guess becomes permanent.

**Alternatives considered**: document only the non-obvious values. Rejected, because nobody agrees which values are obvious.

**Where to look**: the ADR or spec that introduces each value.

---

# Project decisions

Start at ADR-1.

---

## Open decisions

Questions that need an owner's call. Move each one to an ADR when it is decided.

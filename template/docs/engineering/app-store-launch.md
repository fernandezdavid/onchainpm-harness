# First App Store submission

A runbook for the first public release of an iOS app. TestFlight builds go through Beta App Review only; the first App Store version goes through full App Review, and App Store Connect asks for a set of fields that nothing earlier asked for. Most of them are quick. A few need the account holder, a legal answer, or days of lead time.

Apple changes these screens often. Each item below was true for one launch in October 2026. When a screen does not match, trust the screen, then correct this file.

## Start these first

These have lead time, or only the account holder can do them. An agent cannot complete them.

- **EU trader status (DSA).** Since February 2025, an app without verified trader status is not available in the 27 EU countries. Verification is not instant. Apple publishes the trader's name, address, phone and email on the EU product page. For an individual, that is often a home address. Decide the address before you verify, because the verified record is what Apple shows.
- **Agreements.** The Apple Developer Program agreement and the Free Apps agreement must be current. Apple blocks submission until the account holder accepts each new version. Accepting binds the person or the company, so the person accepts it.
- **Legal answers.** The Content Rights question, the age rating floor and the seller name are legal answers. Get them from the owner, and record each answer and its reason in the repository.

## Fields that live only in App Store Connect

| Field | What to know |
| --- | --- |
| Version | Must match the version in the app config. Bump it in the release cut, not earlier: a new version starts a new Beta App Review cycle for TestFlight. |
| Copyright | The legal person or the registered company, not a brand name. |
| Age rating | Apple's 2025 questionnaire rates many topics on their own (for example, health or exercise guidance gives 9+). If the Terms set a minimum age, the rating must align with it. When no band matches, use "Override to Higher Age Rating". |
| App Privacy | Apple counts data as collected only when it leaves the device. Data the app reads and uses on the device (for example, HealthKit readings that stay local) is not declared. Every third-party processor that receives user data counts. |
| Tracking | "No" unless data goes to advertising or data brokers. No App Tracking Transparency prompt is needed then. |
| Export compliance | Declare it in the binary (`ITSAppUsesNonExemptEncryption`). Then App Store Connect does not ask on each upload. |
| License agreement | Apple's Standard EULA is the default. A custom one needs its own legal review. |
| Mac and Vision Pro | iPhone apps are offered on Apple silicon Macs and Vision Pro by default. Opt out unless you tested there. |
| Release | Choose "Manually release this version", so going live is a decision. Phased release is not available for a first version. |
| Product page header art | Optional. Leave it for a later version. |

## Screenshots

- Check which size slot is **required** in the media manager before you capture. In October 2026 the required slot was the 6.1-inch / 6.3-inch iPhone set (1206 x 2622 portrait), and the 6.9-inch set was optional. Earlier documentation said the opposite.
- A simulator of the right device captures at the exact size. Check one file's pixel size before you capture the set.
- Seed realistic data. No empty states, no "0 sessions", no placeholder names. The first three screenshots are what most people see.
- Never commit screenshots. Upload them to App Store Connect directly.

## The review account

App Review signs in with an account you give them. Most first-release rejections that are not about content come from this account.

- **Seed data relative to today.** The reviewer opens the app days after you seed it. Data tied to a calendar week or a date can expire before review starts. Seed relative to the current date, and verify the state the reviewer will see, not only that the seed ran.
- **Make the reseed safe to repeat.** A reviewer can change the account, and a rejection means a second review. A reseed command that resets the account to the seeded state saves a day.
- **Sign-in must work without your help.** If sign-in sends a code by email, give the reviewer a fixed code for that one account, and say so in the review notes. Map the account and the code to the "Sign-in Information" fields exactly.
- **Gates must be open.** If the app has an allowlist, an early-access wall or a feature flag that keeps new users out, open it in production before you submit. A reviewer who signs up with their own Apple ID and meets a closed wall is a rejection.
- **Consent flows run first.** If the app asks for a permission before data reaches a third party (an AI provider, for example), the review account must see that step, and the server must refuse without it.

## Review notes

- The Notes field has a 4,000-character limit. Write it in the repository, check the length, then paste it.
- Say how to sign in, where the main flow starts, and what needs data or hardware the reviewer may not have.
- If a feature depends on a third party (Sign in with Apple, a health integration), say what the reviewer sees without it.

## The build

- **One build number per attempt.** With remote auto-increment, a failed build still uses its number. Tag the commit with the number that shipped, not the one you planned.
- **Run the preflight from a clean checkout.** Build tooling that fingerprints the project (for example, Expo's fingerprint runtime policy) breaks when `node_modules` is a symbolic link to another checkout: the fingerprint includes paths outside the project, and the remote build computes a different runtime version. Run a fresh install in the build checkout.
- **Preflight reads its inputs from the environment.** When you build from a worktree without env files, export the variables the preflight needs for that one command. Never copy env files into the worktree.
- **Write TestFlight notes for the group that tests.** "What to Test" is per build. Keep it in the repository next to the store copy.

## After submission

- Watch for App Review messages. Answer from the repository's review notes, and update them when the answer adds something.
- After approval, release by hand. Then set up phased release for the next version.
- Link the App Store listing from the website and from any install page in the same change.

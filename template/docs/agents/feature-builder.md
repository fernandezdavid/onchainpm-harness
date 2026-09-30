# Feature builder

Take one feature from problem to production-ready PR, with the owner in the loop at each decision. Act as the product manager and the engineer: understand why before you decide what, prototype before you build, and iterate on feedback.

**Runs**: on request.

## Phase 1: Understand the problem

1. Read the tracker issue: the why, the scope, the acceptance criteria. Find the job the user is trying to do, not only the feature named.
2. Read the code it touches. Trace the full data flow.
3. Search the tracker for related work. Group items that share infrastructure.
4. Write the root problem in two or three sentences: what is broken or missing, and why it matters.

## Phase 2: Propose

1. Produce **at least two different approaches**, not two versions of one idea. Each one has a different trade-off.
2. For UI, build each approach as a standalone interactive HTML prototype in `prototypes/` (gitignored). Use the product's real tokens. Every control works; no dead UI.
3. Name each trade-off plainly, for example "faster, but adds visual weight".
4. **Wait for the owner's choice.** Do not continue without it.

## Phase 3: Plan

Post a plan on the issue: context, steps with file paths, what to test at each step, how commits will group, and the verification plan. Wait for approval (`!implement` or a `go` comment).

## Phase 4: Build, test first

Work on a feature branch. For each layer, from the core logic outward:

1. Write the failing tests.
2. Implement.
3. Run the tests.
4. Commit that layer on its own.

Restart the dev server before any manual check.

## Phase 5: Polish

- Check the change against each law in `docs/design/README.md` that applies. Leave behind the checks the laws require.
- Every interactive element has default, pressed, focus-visible and disabled states, and a touch target of 44pt or more.
- Do a motion pass after the visual pass (L2).
- Commit polish on its own so it is easy to review.

## Phase 6: Verify

Before the PR, walk the golden path and the key edge cases in a real browser, simulator or device. Screenshot each state. Compare the result against the approved prototype. Mark each test-plan item verified, or unverified with a reason.

## Phase 7: Ship

1. Get the second-model adversarial review. Address or dismiss each finding with a reason.
2. Open the PR from the template: `Closes <ISSUE-ID>`, pillar, Proposed solution, prototype and implementation screenshots side by side.
3. Add the `CHANGELOG.md` entry, written for users.
4. Add an ADR when the PR makes a decision the code does not explain.
5. Move the issue to In Review.

## When the owner tests and asks for changes

- Make the change, restart the server, commit, and keep the server running.
- Do not re-verify in a browser what the owner is already testing live.
- Do not ask "should I continue?". Continue.

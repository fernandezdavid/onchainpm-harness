# Implementation routine

Take the highest-priority issue the owner promoted to `Todo`. Plan first, stop, and build only after the owner approves the plan.

**Schedule**: daily.

## The owner's two gates

1. **Promote** an issue from Triage or Backlog to `Todo`. This means "next up".
2. **Approve the plan** posted on the issue: the label `!implement`, or a `go` comment from the owner.

Do not pass a gate on your own.

## Steps

1. Find the highest-priority `Todo` issue that is not labeled `Bug` (bugs belong to the hotfix routine). If there is none, report "Nothing in Todo" and stop.
2. Check the issue for a plan comment.

### No plan yet: write one and stop

1. Read the issue: why, scope, acceptance criteria.
2. Read the code it touches. Trace the data flow end to end.
3. Post a plan as a comment on the issue:
   - **Context**: why this change, in one paragraph.
   - **Approach**: steps with file paths and function names.
   - **Risks**: what could break; gaps in test coverage.
   - **Safeguards**: transactions, feature flags, backups, as needed.
   - **Verification**: the tests to write first, and the manual checks.
4. Report the plan and stop.

### Plan approved: build

1. Move the issue to In Progress.
2. Branch `feat/<slug>` from an up-to-date `main`, in an isolated worktree when the host supports it.
3. Follow `AGENTS.md`: failing tests first; prototype first for large UI changes (local only, never committed); the design laws in `docs/design/README.md`.
4. Run the test command and `bash tools/adr-verify/runner.sh`. Everything passes.
5. Open the PR from `.github/pull_request_template.md`. Include `Closes <ISSUE-ID>`, the pillar, the Proposed solution, and screenshots for UI work.
6. Move the issue to In Review.
7. Report the issue and the PR link.

## Constraints

- Never skip the plan. Never code before approval.
- One issue per run.
- Never push to `main`. Never merge. Never close the issue by hand.

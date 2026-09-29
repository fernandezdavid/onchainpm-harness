# Hotfix routine

Find the highest-priority open bug and fix it in a PR. Speed over ceremony, but never skip the regression test.

**Schedule**: hourly, or on request.

## Steps

1. List open issues labeled `Bug` that are not In Progress, In Review or Done. Sort by priority. Skip issues another agent or person already claimed.
2. If there are none, report "No bugs to fix" and stop.
3. For the top bug:
   1. **Investigate.** Read the code the issue names. Confirm the bug is real and the reproduction is complete. If you are not sure it is a bug, comment on the issue for the owner and stop.
   2. **Claim it.** Move the issue to In Progress.
   3. **Branch.** Create `hotfix/<slug>` from an up-to-date `main`, in an isolated worktree when the host supports it.
   4. **Test first.** Write a regression test that fails for the right reason. Run it and confirm the failure.
   5. **Fix.** The smallest change that makes the test pass. No refactoring and no unrelated cleanup.
   6. **Check.** Run the full test command from `AGENTS.md` § Core Commands and `bash tools/adr-verify/runner.sh`. Everything passes.
   7. **Open the PR.** Title `[Hotfix] <description>`. The body says what the bug was, its root cause, what the fix does, and the test plan. Include `Closes <ISSUE-ID>`. If the bug came from user feedback, quote it (H-4).
   8. **Move the issue to In Review.** The tracker closes it when the PR merges.
4. Report the issue, the root cause and the PR link.

## Do not auto-fix

- Anything that touches auth, the database schema, payments, or the data named in `AGENTS.md` § Non-Negotiables. File your diagnosis as a comment instead.
- Bugs whose fix you are less than 90% sure of.
- Bugs that need a device or a browser you cannot run. Say so in the PR as "needs manual verification".

## Constraints

- Never push to `main`. Never merge.
- Never close the issue by hand.

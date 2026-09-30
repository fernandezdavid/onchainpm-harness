# Adopt the harness

This project existed before it took the harness (version in `.harness-version`). `bin/adopt` added the harness files that were missing, on the branch `harness/adopt`. Where the project already had a file, the harness version waits in `.harness/incoming/<path>`. Nothing the project had was changed.

This file tells the agent how to finish the adoption. Delete it when `bash scripts/check-bootstrap.sh` passes.

The template assumes GitHub: Actions workflows, a PR template, and a Cursor rule that posts reviews with `gh`. On another Git host, replace those first.

## For the agent

Work on `harness/adopt`. The adoption PR changes docs, config and checks only. It does not change product code. When the harness shows a gap in the product, file an issue; do not fix it here.

1. **Look first.** Run `bash scripts/check-bootstrap.sh`. It lists the open `TODO(bootstrap)` slots and the staged files in `.harness/incoming/`.
2. **Find every rule the project already has.** Look for `AGENTS.md` and `CLAUDE.md` at every level, `.cursorrules`, `.cursor/rules/`, `.github/copilot-instructions.md`, `GEMINI.md`, `.windsurfrules`, and contributing or convention docs. Show the user the list.
3. **Build one `AGENTS.md`.** Merge those rules into the harness skeleton (`.harness/incoming/AGENTS.md` if the project had an `AGENTS.md`, else the new `AGENTS.md`). Keep the project's rules; they win over the template where they conflict. Keep the line budgets: move area rules to a nested `AGENTS.md` and runbooks to `docs/`. Each `CLAUDE.md` keeps only Claude-only notes and imports `@AGENTS.md`. Ask the user before you delete another tool's rules file; the usual answer is to replace its content with a pointer to `AGENTS.md`.
4. **Fill the slots from the code, then ask.** Read the manifests, the CI config, the README and the git history. Fill what they answer in `AGENTS.md` (repository map, commands, invariants) and show the user what you found. Ask the user only for what the code cannot answer, one topic at a time:
   1. What the product is and who it is for: `STRATEGY.md` and `AGENTS.md` § Product Rules.
   2. The data that must never be lost: the Non-Negotiable in `AGENTS.md` and the matching section of `.cursor/BUGBOT.md`.
   3. The tracker and the state new issues start in: `AGENTS.md` and `WAYS_OF_WORKING.md`.
   4. The review surface for UI: a local URL (web app) or the simulator and a dev build (native app).
   5. The design system and voice docs, and who the product is for: `docs/design/README.md`.
   Do not invent answers. When the user does not know yet, write the question as an open decision and remove the marker.
5. **Offer the design skill setup.** Ask the user whether to run the impeccable teach skill (`teach-impeccable`) now. It interviews the user and writes `.impeccable.md`, the context that critique, polish and audit read.
   1. Check that you have the skill. It is in your skill list; in Claude Code, `claude plugin list` shows `impeccable`.
   2. If you do not, offer to install it, and wait for a yes: it changes the user's machine, not the project. In Claude Code, run `claude plugin marketplace add pbakaus/impeccable`, then `claude plugin install impeccable@impeccable`. For another agent, follow the steps for that agent in the impeccable README. If the skill does not appear after the install, ask the user to open a new session and continue this file from this step.
   3. Run the skill after step 4, so it starts from the filled canon. When it offers to add its context to `AGENTS.md`, decline: the canon owns that context, and `AGENTS.md` has a line budget (H-1). If the project already has `.impeccable.md`, check it against the canon instead of running the skill again.
   4. Record the answer in the last row of "Start here" in `docs/design/README.md`: `.impeccable.md`, "none", or an open decision.
6. **Record what the project already decided.** Write the important decisions the code and history show as project ADRs, from ADR-1 (or after the project's last ADR). If the project already keeps ADRs elsewhere, keep them there and point `AGENTS.md` at them.
7. **Compare the project with the harness defaults.** For each of H-1 to H-11 in `docs/engineering/decisions.md`, and each law in `docs/design/README.md`: the project follows it, or it supersedes it with a project ADR, or it breaks it today. For each one it breaks today, file an issue. Do not claim a default the code does not follow.
8. **Merge the staged files.** For each file in `.harness/incoming/`, merge what the project lacks into the project's file (for example the `.gitignore` entries or the PR template sections). Then delete `.harness/`.
9. **Check CI.** `.github/workflows/harness.yml` runs the harness checks beside the project's own CI. If no workflow runs the project's tests, tell the user.
10. **Protect `main`.** Ask the user to require a PR and a green CI before merge on the Git host.
11. **Finish.** Run `bash scripts/check-agent-memory.sh`, `bash tools/adr-verify/runner.sh` and `bash scripts/check-bootstrap.sh`. All pass means the adoption is done. Delete this file in the same commit, and open one PR for the whole adoption.

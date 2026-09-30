# Bootstrap

This project was created from `onchainpm-harness` (version in `.harness-version`). The harness gives you the working rules, the checks, and empty slots. This file tells the first agent session how to fill the slots. Delete this file when `bash scripts/check-bootstrap.sh` passes.

The template assumes GitHub: Actions workflows, a PR template, and a Cursor rule that posts reviews with `gh`. On another Git host, replace `.github/` and `.cursor/rules/pr-review-github.mdc` first.

## For the agent running the first session

1. Run `bash scripts/check-bootstrap.sh`. It lists every `TODO(bootstrap)` marker with its file and line.
2. Interview the user for the answers. Ask one topic at a time, in this order:
   1. What the product is, who it is for, and where they use it. Fill `STRATEGY.md` and `AGENTS.md` § Product Rules.
   2. The stack and the commands. Fill `AGENTS.md` § Repository Map, § Core Commands and § Architecture Invariants, and the test step in `.github/workflows/ci.yml`.
   3. The data that must never be lost. Fill the Non-Negotiable in `AGENTS.md` and the matching section of `.cursor/BUGBOT.md`. Then write the project's first ADR and its drift check.
   4. The tracker: tool, team, project, the state new issues start in. Fill `AGENTS.md` and `WAYS_OF_WORKING.md`.
   5. The review surface for UI: a local URL (web app) or the simulator and a dev build (native app).
3. Do not invent answers. When the user does not know yet, write the question into the file as an open decision and remove the marker.
4. Fill `docs/design/README.md`: the design system and voice docs in "Start here" (or "not yet"), and "Who this is for". Then review the laws with the user. Keep, change or delete each one. A law you keep needs a check this project can run.
5. Ask the user whether to run the impeccable teach skill (`teach-impeccable`) now. It interviews the user and writes `.impeccable.md`, the context that critique, polish, audit and animate read.
   1. Check that you have the skill. It is in your skill list; in Claude Code, `claude plugin list` shows `impeccable`.
   2. If you do not, offer to install it, and wait for a yes: it changes the user's machine, not the project. In Claude Code, run `claude plugin marketplace add pbakaus/impeccable`, then `claude plugin install impeccable@impeccable`. For another agent, follow the steps for that agent in the impeccable README. If the skill does not appear after the install, ask the user to open a new session and continue this file from this step.
   3. Run the skill after step 4, so it starts from the filled canon. When it offers to append its Design Context to your rules file (`CLAUDE.md` in Claude Code, `.cursorrules` in Cursor, `AGENTS.md` or `GEMINI.md` elsewhere), decline: the canon owns that context, and agent memory stays on a budget (H-1).
   4. Record the answer in the "design skill context" row of "Start here" in `docs/design/README.md`: `.impeccable.md`, "none", or an open decision.
6. Read `docs/engineering/decisions.md`. H-1 to H-11 are harness defaults from earlier projects. Supersede any that do not fit with a project ADR. Do not delete them. Project ADRs start at ADR-1.
7. Ask the user to protect `main` on the Git host: require a PR and a green CI before merge. The rule "never push to `main`" holds only when the host enforces it.
8. Run the three checks in `AGENTS.md` § Core Commands. All pass means the bootstrap is done. Delete this file in the same commit.

## What the harness does not decide

- The stack, the deploy target and the tracker.
- The design system: tokens, type and palette.
- Which scheduled routines under `docs/agents/` to turn on. Start with none. Add one when the manual version of that job hurts.

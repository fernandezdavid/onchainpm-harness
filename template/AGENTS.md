# AGENTS.md

Shared project memory for every AI coding agent in {{PROJECT_NAME}}. Keep this file compact. Move area-specific instructions to the nearest nested `AGENTS.md`, or to long-lived docs under `docs/engineering/` and `docs/product/`.

`CLAUDE.md` imports this file. Do not add `@path` imports here unless every Claude Code session needs that content at startup.

## Memory Budget

- Root `AGENTS.md` stays under 150 lines. Root `CLAUDE.md` stays under 40 lines.
- Each nested `AGENTS.md` or `CLAUDE.md` stays under 100 lines.
- Put new guidance in the narrowest file that covers it. Add it here only when it applies to every agent session.
- When a rule needs examples or a runbook, keep the rule here and move the detail to `docs/`.
- `scripts/check-agent-memory.sh` enforces these budgets in CI.
- A nested folder gets an `AGENTS.md` plus a one-line `CLAUDE.md` that contains `@AGENTS.md`.

## Repository Map

TODO(bootstrap): list each top-level folder with one line on what it holds. Point to its nested `AGENTS.md` when it has one.

- `docs/` - Product strategy, engineering specs, ADRs, and the design canon.
- `tools/adr-verify/` - Checks that ADR claims still hold in the code.

## Core Commands

TODO(bootstrap): install, test, run one test file, lint, start the dev server. State the local dev port.

Run the harness checks from the repository root:

```bash
bash scripts/check-agent-memory.sh
bash tools/adr-verify/runner.sh
bash scripts/check-bootstrap.sh
```

## Architecture Invariants

TODO(bootstrap): the few structural rules that every change must respect (layering, where side effects may live, the source of truth for the schema).

## Non-Negotiables

- Use a feature branch and a PR for every change. Never push to `main`.
- Write the failing test first for new features and bug fixes. CSS-only and HTML-only changes are exempt.
- TODO(bootstrap): name the data this product must never lose, and the one write path allowed to change it. Guard it with an ADR and a drift check.
- Record non-obvious decisions in `docs/engineering/decisions.md`. When an ADR claims an invariant, add a check under `tools/adr-verify/checks/`.
- Active work lives in the tracker, not in markdown. TODO(bootstrap): name the tracker, team and project, and the state new issues start in.
- User-facing changes need a `CHANGELOG.md` entry.
- Stage explicit paths only. Never `git add -A` or `git add .`. Other people's unfinished work may be in the tree.

## When You Push Back

When you refuse a request or block an action, state three things: the rule it breaks, where that rule lives (file or ADR), and the compliant alternative. Never refuse without a path forward.

## PR Expectations

- Link the relevant pillar in `STRATEGY.md` and each engineering spec or ADR the PR touches.
- When a PR or issue addresses user feedback, quote the user verbatim with the source and date. A summary alone is not enough (H-4).
- Every PR that changes behavior needs a plain-language **Proposed solution** section: what was wrong, what we chose, and the trade-offs (H-4).
- UI PRs need screenshots of each affected state. Never commit screenshots. Attach them to the PR.
- Restart the dev server after code changes, before you test the UI.
- Before you push new features, substantive changes or bug fixes, get an adversarial review from a different model than the one that wrote the code.

## Product Rules

TODO(bootstrap): who the users are, where and how they use the product, and the voice. Keep it to the rules that change daily decisions.

## Design Direction

- Read `docs/design/README.md` before any UI or interaction work. It holds the laws and the check for each one. To break a law, raise it and change the law.
- TODO(bootstrap): name the design system source (tokens, components) once it exists.

## Read Before Touching

| Area | Read first |
|---|---|
| Any UI or interaction | `docs/design/README.md` |
| Decisions and their reasons | `docs/engineering/decisions.md` |
| How work flows (tracker, agents, gates) | `WAYS_OF_WORKING.md` |
| Scheduled agent routines | `docs/agents/README.md` |

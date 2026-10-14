# Ways of working

How we build {{PROJECT_NAME}}: where work lives, who decides, and the gates between an idea and production.

## Where things live

| What | Where |
|---|---|
| Strategy and pillars | `STRATEGY.md` |
| Active work: features, bugs, proposals | The tracker. TODO(bootstrap): tool, team, project. |
| Decisions and their reasons | `docs/engineering/decisions.md` (ADRs) |
| Design laws | `docs/design/README.md` |
| Shipped user-facing changes | `CHANGELOG.md` |
| Rules for agents | `AGENTS.md`, plus nested `AGENTS.md` files |

Rule of thumb: short-lived work (one feature, one bug, one proposal) goes in the tracker. Knowledge that outlives a single feature goes in markdown (H-3).

## The pipeline

```
Feedback or idea
  -> Triage       (agent files an issue with the verbatim quote; the owner triages)
  -> Todo         (the owner promotes it: gate 1)
  -> Plan         (agent posts a technical plan on the issue and stops)
  -> Approved     (the owner approves the plan: gate 2)
  -> Build        (branch, failing test first, implementation, checks)
  -> Review       (second-model adversarial review, then the owner reviews the PR)
  -> Merge        (the owner merges; nobody else)
  -> Release      (tagged release with notes; merge pace is not ship pace, H-10)
```

Bugs skip gate 2 when the fix is small and covered by a regression test. Everything else passes both gates.

## Issue states

| State | Who moves it there |
|---|---|
| Triage | Agents file here. The tracker's API default is often Backlog; set Triage explicitly. |
| Backlog | The owner, when an issue is real but not next. |
| Todo | The owner. This means "next up". |
| In Progress | The agent or person working on it. |
| In Review | Whoever opens the PR. Put `Closes <ISSUE-ID>` in the PR body. |
| Done | The tracker, when the PR merges. Never close an issue by hand. |

## Conventions

- **Branches:** `feat/<slug>`, `fix/<slug>`, `hotfix/<slug>`. Branch from `main`, PR back to `main`.
- **PR size:** one PR per logical change. Bundle related sub-issues. Stack PRs only when the owner agrees; then merge from the bottom up.
- **Prototypes:** build big UI changes as a standalone HTML prototype with at least two variations. Prototypes stay local in `prototypes/` (gitignored).
- **Screenshots:** attach to the PR, never commit. Stage them in `/tmp/<repo>-pr-screenshots/<branch>/`.
- **Bulk data changes:** dry run to a JSON file, the owner reviews it, then apply in batches that stop on the first failure.
- **Review comments:** reply with the fix or the reason, then resolve the thread.

## Scheduled routines

Routine prompts live in `docs/agents/`. Each one runs on a schedule in whichever agent host you use. Turn one on only when the manual version of that job hurts.

# Agent routines

Prompts for agents that run on a schedule or on request. They are plain markdown, so any agent host can run them: Claude Code routines (`/schedule`), Codex automations, Cursor background agents, or a person who pastes one in.

They are not Claude Code subagent definitions. Do not move them into `.claude/agents/`; that folder expects frontmatter these files do not have.

| Routine | Job | Suggested schedule | Never does |
|---|---|---|---|
| [feedback-triage](feedback-triage.md) | Pulls new user feedback, removes duplicates, files issues in Triage | Daily | Implements features; writes to the database |
| [hotfix](hotfix.md) | Fixes the highest-priority open bug in a PR | Hourly, or on request | Refactors; merges |
| [implementation](implementation.md) | Plans the top `Todo` issue, then builds it after approval | Daily | Codes before the plan is approved |
| [feature-builder](feature-builder.md) | Takes one feature from problem to PR, with the owner in the loop | On request | Skips prototypes for UI |

## Gates that every routine respects

- The owner is the only person who promotes issues, approves plans and merges PRs.
- A routine opens PRs. It never merges them.
- A routine that finds nothing to do reports that and stops. It does not invent work.

## Turning one on

Start with none. Turn a routine on when the manual version of its job hurts. Each routine reads the project facts it needs (tracker, test command, feedback source) from `AGENTS.md` and `WAYS_OF_WORKING.md`. Fill those before the first run.

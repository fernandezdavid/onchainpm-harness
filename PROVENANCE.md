# Provenance

Where each harness default was learned. The template itself stays product-neutral (see `AGENTS.md`), so the source of each default is recorded here instead.

## Decision defaults (`template/docs/engineering/decisions.md`)

| Default | Source |
|---|---|
| H-1 Agent memory is one shared file, layered, on a budget | Fire Your Coach: root `AGENTS.md` memory budget and `scripts/check-agent-memory.mjs` |
| H-2 An ADR that claims an invariant carries a drift check | Fire Your Coach: `tools/adr-verify/` |
| H-3 Short-lived work in the tracker, lasting knowledge in markdown | Fire Your Coach: `WAYS_OF_WORKING.md` |
| H-4 Feedback PRs carry the verbatim quote and a proposed solution | Fire Your Coach ADR-58 |
| H-5 Migrations are clean-slate | Fire Your Coach ADR-26 |
| H-6 Canonical components, enforced by a ratchet | Fire Your Coach ADR-49 |
| H-7 A surface never renders nothing; a failure is never silent | Fire Your Coach ADR-61; Robot Money empty-state rule |
| H-8 Three telemetry sinks; no session replay | Fire Your Coach ADR-65 and ADR-66 |
| H-9 Every scheduled job leaves a pulse | Fire Your Coach ADR-73 |
| H-10 Tagged release train | Fire Your Coach ADR-60 |
| H-11 Values that change user outcomes carry a source | Fire Your Coach agent memory ("research-backed decisions") |

## Design laws (`template/docs/design/README.md`)

| Law | Source |
|---|---|
| L1 to L12 | Fire Your Coach design canon, laws L1 to L12 |
| L12 (redundancy clause) | Robot Money copy rule: no facts already on screen |
| L13 A number states its basis | Robot Money: changes in percentage points |

## Personal rules (`global/AGENTS.md`)

Extracted from 84 feedback and user memories across 12 projects' Claude Code auto-memory, plus the house rules of a team context repository and the previous `~/.claude/CLAUDE.md`. Private details (addresses, workspace names, private repositories) moved to the git-ignored `global/AGENTS.local.md`. Rules that applied to one product only stayed in that product.

## Routines (`template/docs/agents/`)

Fire Your Coach `.claude/agents/`: discovery and feedback-triage (merged into `feedback-triage.md`), hotfix, implementation, feature-builder.

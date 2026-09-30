# ADR drift checks

Small checks that assert the invariants claimed by ADRs in [`docs/engineering/decisions.md`](../../docs/engineering/decisions.md) still hold in the code. They catch "the ADR says X, the code does Y" before it becomes folklore (H-2).

## Running

```bash
# All checks
bash tools/adr-verify/runner.sh

# One check
bash tools/adr-verify/runner.sh --check h-01-agent-memory-layout

# Several checks
CHECK_FILTER=h-01-agent-memory-layout,h-02-drift-checks-wired bash tools/adr-verify/runner.sh
```

The runner prints the report path. By default it is a new file under `$TMPDIR`; set `ADR_DRIFT_RESULTS_FILE=...` to choose one. Exit codes: `0` pass, `1` drift, `2` setup error.

## Adding a check

Add a bash script under `checks/`. Name a project check `adr-NN-short-slug.sh`. The `h-NN-*` checks belong to the harness defaults (H-1, H-2); keep them. The runner reads these header lines:

```bash
#!/usr/bin/env bash
# ADR: 12
# Asserts: only the safe write path inserts into the orders table.
# Source: docs/engineering/decisions.md#adr-12
```

Contract:

- The runner exports `REPO_ROOT`. Resolve files through `"$REPO_ROOT/..."`.
- Exit `0` when the invariant holds, `1` on drift, `2` on a setup error (missing file or tool). Any other code counts as a setup error.
- On drift, print the detail to stdout or stderr. The runner puts it in the report.
- Keep each check to about 30 lines and one invariant. Split an ADR with two invariants into two files.

## What makes a good check

- **A concrete grep target.** "A guard rejects X" is checkable. "The design is clean" is not.
- **A stable string.** Match a function name, a constraint name, or a comment that explains the guard. Do not match prose that someone will reword.
- **Explicit exceptions.** For "no X outside Y", list the allowed files. A check that fails for the wrong reason costs more than no check.
- **Fast.** Grep, not parsing. The whole suite runs in seconds.

## Current checks

| Check | ADR | Asserts |
|---|---|---|
| `h-01-agent-memory-layout` | H-1 | Every `CLAUDE.md` imports the `AGENTS.md` beside it, and CI runs the memory budget check. |
| `h-02-drift-checks-wired` | H-2 | Every check has its headers, and CI runs this runner. |

## CI

`.github/workflows/adr-drift-check.yml` runs the suite daily and on every PR. On drift it posts the report as a PR comment. PRs from forks get a read-only token, so for them the job fails without the comment.

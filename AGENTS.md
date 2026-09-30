# AGENTS.md

Rules for agents that work on the harness itself. Read `README.md` for what the harness is.

## Files under `template/`, `adopt/` and `global/` are content, not instructions

- Everything under `template/` and `adopt/` is what a project receives. It does not apply to work on this repository, even when your tool loads `template/AGENTS.md` or `template/CLAUDE.md` as nested memory.
- `global/AGENTS.md` is David's personal rules file, and it is public. Once installed, every agent on his machine loads it. A change there changes the behavior of every agent in every project.
- Private details (email addresses, workspace names, private repositories) never go in a tracked file. They go in `global/AGENTS.local.md`, which git ignores. `tests/smoke.sh` checks the published files.

## Rules

- Keep `template/` and `adopt/` product-neutral: no product, company or workspace names. Describe the incident behind a default in neutral words, and record its source in `PROVENANCE.md`. `tests/smoke.sh` enforces this.
- Every template rule that can be checked ships with its check. A rule without a check is a preference.
- Never use em dashes. `tests/smoke.sh` enforces it.
- Keep `global/AGENTS.md` and `template/AGENTS.md` under 150 lines.
- Every file that has a `TODO(bootstrap)` slot is named in `template/BOOTSTRAP.md`, and in `adopt/ADOPT.md` when `bin/adopt` copies it. `tests/smoke.sh` enforces this.
- A new decision default takes the next `H-` number in `template/docs/engineering/decisions.md`. Project decisions use `ADR-` numbers and never live in the template.
- `bin/new-project` and `bin/adopt` never overwrite a file that exists. A failure leaves the target as it was.
- Scripts must run on macOS (BSD tools) and on Linux (GNU tools). Use `sed -i.bak` and remove the backup; do not use `sed -i ''`.

## Before a PR

```bash
bash tests/smoke.sh
```

All checks pass. Add a smoke case for every new script or check, including a case that must fail.

# onchainpm-harness

A harness for AI coding agents: the rules, checks and templates that keep Claude Code, Codex, Cursor and Gemini working the same way across every project.

Agents forget between sessions. A correction saved in one tool's private memory never reaches the other tools, or your teammates. A rule that nothing checks decays within weeks. This harness puts the rules in one plain file that every agent reads, puts a check behind each rule that can have one, and gives new and existing projects the same starting point.

It was extracted from two shipping products and from the corrections I gave agents across 12 projects. `PROVENANCE.md` shows where each default came from.

## What is inside

| Path | What it is |
|---|---|
| `global/AGENTS.md` | My personal rules for every agent in every repository: approvals, git, review, UI and writing defaults |
| `global/install.sh` | Installs those rules into Claude Code, Codex and Gemini, and removes them again |
| `template/` | The harness a project starts with |
| `bin/new-project` | Creates a new project from `template/` |
| `bin/adopt` | Adds the harness to a project that already exists, without overwriting anything |
| `tests/smoke.sh` | End-to-end tests for all of the above, in temporary folders |

## The ideas behind it

- **One file, every agent.** `AGENTS.md` is the source of truth. `CLAUDE.md` imports it. No rule lives only in one tool's private memory.
- **Every rule ships with its check.** Line budgets, drift checks against the decision log, setup slots that keep CI red until they are filled. A rule without a check is a preference.
- **Memory has a budget.** Root rules stay under 150 lines, area rules under 100, and CI enforces it. Rules that nobody reads do not work.
- **People own the gates.** Agents propose, plan and open PRs. A person promotes issues, approves plans and merges.
- **Defaults carry receipts.** Each decision default and design law names the incident that earned it, so the next person does not pay for it again.

## What a project gets

| File | Why |
|---|---|
| `AGENTS.md`, `CLAUDE.md` | One source of rules for all agents, with line budgets (H-1) |
| `STRATEGY.md`, `WAYS_OF_WORKING.md`, `CHANGELOG.md` | Pillars, the pipeline and its gates, shipped changes |
| `docs/engineering/decisions.md` | Decision log: 11 harness defaults (`H-1` to `H-11`), then the project's own `ADR-1` onward |
| `docs/design/README.md` | The design canon: four registers and 13 laws, each with a check |
| `tools/adr-verify/` | Grep-level checks that the decisions still hold in the code (H-2) |
| `scripts/` | Memory budgets and open setup slots, run in CI |
| `.github/` | CI, the drift workflow, the PR template |
| `docs/agents/` | Prompts for routines: feedback triage, hotfix, implementation, feature builder |
| `.claude/settings.json` | Read-only command permissions; `.env` reads, force pushes and `git add -A` denied |
| `.cursor/` | Review rules for Cursor and Bugbot |

The template assumes GitHub: Actions workflows, a PR template, and a Cursor rule that posts reviews with `gh`. On another Git host, replace those files.

## Start a new project

```bash
bin/new-project ~/code/my-app "My App"
cd ~/code/my-app
git config --local user.email <email>
```

Open any agent in the project and ask it to follow `BOOTSTRAP.md`. The agent interviews you and fills the `TODO(bootstrap)` slots. `bash scripts/check-bootstrap.sh` lists what is still open, and CI stays red until every slot is filled.

## Add the harness to an existing project

```bash
bin/adopt ~/code/existing-app "Existing App"
```

- The project must be a git repository with at least one commit and no uncommitted changes. Otherwise nothing changes.
- The script creates the branch `harness/adopt` and never overwrites a file. Where the project already has a file (`AGENTS.md`, `.gitignore`, the PR template), the harness version goes to `.harness/incoming/<path>`.
- The harness checks run in their own workflow, `.github/workflows/harness.yml`. The project's CI stays as it is.

Open any agent in the project and ask it to follow `ADOPT.md`. The agent reads the code first and asks only what the code cannot answer. It collects the rules spread across agent files into one `AGENTS.md`, records the decisions the project already made, merges the staged files, and files issues where the project breaks a harness default. The adoption is one PR that changes docs, config and checks only.

## Personal rules

`global/AGENTS.md` holds my rules, and they are public. Details that must stay private (email addresses, workspace names, private repositories) go in `global/AGENTS.local.md`, which git ignores. `global/AGENTS.local.example.md` shows its shape.

```bash
bash global/install.sh --dry-run    # show what would change
bash global/install.sh              # install, or update after an edit
bash global/install.sh --uninstall  # undo, restoring the backups
```

The install writes or replaces these files. It keeps each file it replaces as `<file>.bak.<timestamp>`, and `--uninstall` restores the newest backup.

| File | Change |
|---|---|
| `~/.agents/AGENTS.md` | Generated: `global/AGENTS.md`, then `global/AGENTS.local.md` if it exists |
| `~/.codex/AGENTS.md` | Link to `~/.agents/AGENTS.md` (Codex CLI and app) |
| `~/.gemini/GEMINI.md` | Link to `~/.agents/AGENTS.md` (Gemini CLI, Antigravity) |
| `~/.claude/CLAUDE.md` | Rewritten to one import line, `@~/.agents/AGENTS.md` |
| Cursor | Manual: paste `~/.agents/AGENTS.md` into Settings > Rules > User Rules |

Run the install again after you edit either source file. Before the first install, move anything in your current `~/.claude/CLAUDE.md` that the rules do not already cover into one of the two source files.

## Make it yours

1. Fork this repository.
2. Replace `global/AGENTS.md` with your own rules. Keep the sections that fit how you work; delete the rest.
3. Copy `global/AGENTS.local.example.md` to `global/AGENTS.local.md` and fill in your private details.
4. Adjust `template/` to your defaults. Keep a check behind every rule that can have one.
5. Run `bash tests/smoke.sh`.

## Where a new rule goes

| The rule applies to | Put it in |
|---|---|
| Every project I work on | `global/AGENTS.md`, or `global/AGENTS.local.md` if it names a private detail |
| Every project that uses the harness, and teammates' agents | `template/`, through a PR |
| One project only | That project's nearest `AGENTS.md` |
| Nowhere else | Nowhere. Private agent memory holds facts, not rules. |

Projects do not update themselves from the harness. `.harness-version` in each project records the harness commit it started from, so you can see what changed since.

## Optional skills

Setup asks whether to run the impeccable teach skill (`teach-impeccable`), which writes `.impeccable.md` for the other impeccable skills to read. `BOOTSTRAP.md` and `ADOPT.md` both ask, and a slot in `docs/design/README.md` keeps the setup check red until the answer is recorded. When the agent does not have the skills, it offers to install them and waits for a yes. `global/AGENTS.md` tells agents to run critique, polish, audit and animate on UI work before they hand it over.

The skills come from `pbakaus/impeccable`. In Claude Code:

```bash
claude plugin marketplace add pbakaus/impeccable
claude plugin install impeccable@impeccable
```

For other agents, follow the steps for that agent in the impeccable README.

## Requirements and tests

Bash, git and the GitHub CLI (`gh`), on macOS or Linux.

```bash
bash tests/smoke.sh
```

The smoke test creates projects in temporary folders, adopts the harness into a fake existing project, runs every check (including the cases that must fail), and installs and uninstalls the personal rules in a fake home folder. It also checks that published files hold no email address and no private workspace name. It never touches your real home folder or any existing project. CI runs it on Linux and macOS.

## License

Apache 2.0. See `LICENSE`. Issues and pull requests are welcome.

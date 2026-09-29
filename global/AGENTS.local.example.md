## Private rules

Copy this file to `global/AGENTS.local.md` and fill it in. Git ignores that name, so it stays on your machine. `global/install.sh` appends it to the public rules. Keep a copy somewhere private, for example your dotfiles, because a fresh clone does not have it.

### Identity

- Personal repositories commit as `<personal email>`. Work repositories commit as `<work email>`.

### Tracker workspaces

- Repositories with `<company>` in the path use the `<company>` workspace. All other repositories use `<personal workspace>`.
- In Claude Code, the MCP server for `<company>` is `<server name>`.

### Security

- These repositories are public: `<org/repo>`. Security findings for them go to `<private place>`.

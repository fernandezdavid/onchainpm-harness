# CLAUDE.md

@AGENTS.md

## Claude Code Notes

- `AGENTS.md` is the source of truth for shared project memory. Keep this file for Claude-specific notes only.
- Claude Code loads nested `CLAUDE.md` files when it reads files in their folders. Keep root memory small and put area guidance beside the code.
- Before a push of new work, `AGENTS.md` asks for a review by a second model. If the Codex plugin is installed, that review is `/codex:adversarial-review`, and only the user can run it: commit, stop before `git push`, and hand over with a one-line summary of the diff. If it is not installed, ask the user how to get the second review.
- Use auto-memory for project facts only. Put corrections in `AGENTS.md` (this project) or in the personal rules file (all projects), so other agents can read them.

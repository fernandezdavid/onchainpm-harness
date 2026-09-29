#!/usr/bin/env bash
# Shared by the harness checks, so they all skip the same folders.
# Source this file; do not run it.

# Folders that hold copies, dependencies, build output or staged harness files, never live agent memory.
HARNESS_SKIP_DIRS=(.git node_modules .claude .cursor .harness dist build coverage .venv vendor)

# Print every AGENTS.md and CLAUDE.md under the current folder, NUL-separated, outside the skipped folders.
harness_find_memory_files() {
  local prune=() dir
  for dir in "${HARNESS_SKIP_DIRS[@]}"; do
    [ ${#prune[@]} -gt 0 ] && prune+=(-o)
    prune+=(-name "$dir")
  done
  find . \( "${prune[@]}" \) -prune -o \( -name AGENTS.md -o -name CLAUDE.md \) -type f -print0
}

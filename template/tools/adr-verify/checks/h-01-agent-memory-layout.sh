#!/usr/bin/env bash
# ADR: H-1
# Asserts: every CLAUDE.md imports the AGENTS.md beside it, and CI runs the memory budget check.
# Source: docs/engineering/decisions.md#h-1

set -uo pipefail
cd "$REPO_ROOT" || exit 2
. "$REPO_ROOT/scripts/harness-paths.sh" || { echo "scripts/harness-paths.sh is missing."; exit 2; }

drift=0

while IFS= read -r -d '' file; do
  [ "$(basename "$file")" = CLAUDE.md ] || continue
  dir="$(dirname "$file")"
  if [ ! -f "$dir/AGENTS.md" ]; then
    echo "${file#./} has no AGENTS.md beside it."
    drift=1
  elif ! grep -qxF '@AGENTS.md' "$file"; then
    echo "${file#./} does not import @AGENTS.md."
    drift=1
  fi
done < <(harness_find_memory_files)

if ! grep -rqF 'scripts/check-agent-memory.sh' .github/workflows/ 2>/dev/null; then
  echo "No workflow under .github/workflows/ runs scripts/check-agent-memory.sh."
  drift=1
fi

exit "$drift"

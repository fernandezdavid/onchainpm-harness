#!/usr/bin/env bash
# Enforce the agent memory line budgets from AGENTS.md § Memory Budget (H-1).
# Root AGENTS.md <= 150 lines, root CLAUDE.md <= 40, every nested AGENTS.md or CLAUDE.md <= 100.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
# shellcheck source=scripts/harness-paths.sh
. "$ROOT/scripts/harness-paths.sh" || exit 2

failures=0
count=0

while IFS= read -r -d '' file; do
  rel="${file#./}"
  case "$rel" in
    AGENTS.md) limit=150 ;;
    CLAUDE.md) limit=40 ;;
    *) limit=100 ;;
  esac
  lines=$(awk 'END { print NR }' "$file")
  count=$((count + 1))
  if [ "$lines" -gt "$limit" ]; then
    echo "  $rel: $lines lines, limit $limit"
    failures=$((failures + 1))
  fi
done < <(harness_find_memory_files)

if [ "$failures" -gt 0 ]; then
  echo "Agent memory files exceed their line budgets. Move detail into nested memory files or docs/."
  exit 1
fi

echo "Agent memory line budgets OK ($count files checked)."

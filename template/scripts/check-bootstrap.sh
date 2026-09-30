#!/usr/bin/env bash
# Fail while any TODO(bootstrap) slot is open, or while staged harness files wait in .harness/incoming/.
# BOOTSTRAP.md (new project) or ADOPT.md (existing project) explains how to close them.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 2
. "$ROOT/scripts/harness-paths.sh" || exit 2

MARKER='TODO(bootstrap)'
status=0

excludes=()
for dir in "${HARNESS_SKIP_DIRS[@]}"; do
  case "$dir" in .claude|.cursor) continue ;; esac # these hold template files with slots
  excludes+=(--exclude-dir="$dir")
done

hits="$(grep -rnF "$MARKER" . "${excludes[@]}" \
  --exclude=BOOTSTRAP.md --exclude=ADOPT.md --exclude=check-bootstrap.sh 2>/dev/null)"

if [ -n "$hits" ]; then
  n=$(printf '%s\n' "$hits" | wc -l | tr -d ' ')
  echo "$n slot(s) still open:"
  printf '%s\n' "$hits"
  status=1
fi

if [ -d .harness/incoming ] && [ -n "$(find .harness/incoming -type f 2>/dev/null)" ]; then
  echo "Staged harness files still wait to be merged:"
  (cd .harness/incoming && find . -type f | sed 's|^\./|  |' | sort)
  status=1
fi

if [ "$status" -ne 0 ]; then
  guide=BOOTSTRAP.md
  [ -f ADOPT.md ] && guide=ADOPT.md
  echo "See $guide."
  exit 1
fi

echo "No open slots and nothing staged."
for guide in BOOTSTRAP.md ADOPT.md; do
  [ -f "$guide" ] && echo "Setup is complete. Delete $guide."
done
exit 0

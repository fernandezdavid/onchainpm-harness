#!/usr/bin/env bash
# ADR: H-2
# Asserts: every drift check names its ADR and its invariant, and CI runs the runner.
# Source: docs/engineering/decisions.md#adr-2

set -uo pipefail
cd "$REPO_ROOT" || exit 2

drift=0

for check in tools/adr-verify/checks/*.sh; do
  grep -qE '^# ADR: *(H-)?[0-9]+$' "$check" || { echo "$check has no '# ADR: N' or '# ADR: H-N' header."; drift=1; }
  grep -qE '^# Asserts: .+' "$check" || { echo "$check has no '# Asserts:' header."; drift=1; }
done

if ! grep -rqF 'tools/adr-verify/runner.sh' .github/workflows/ 2>/dev/null; then
  echo "No workflow under .github/workflows/ runs tools/adr-verify/runner.sh."
  drift=1
fi

exit "$drift"

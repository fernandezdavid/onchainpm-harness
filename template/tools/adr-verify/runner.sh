#!/usr/bin/env bash
#
# tools/adr-verify/runner.sh
#
# Discovers ADR drift checks under tools/adr-verify/checks/, runs each
# against the repo at $REPO_ROOT, and aggregates results to a markdown
# report. Each check is a self-contained bash script that asserts a single
# invariant claimed by an ADR in docs/engineering/decisions.md.
#
# Environment:
#   REPO_ROOT                  Repo root. Default: `git rev-parse --show-toplevel`.
#   CHECK_FILTER               Optional. Comma-separated check names
#                              (filename without .sh) to run. Empty = run all.
#   ADR_DRIFT_RESULTS_FILE     Output report path. Default: a new file under ${TMPDIR:-/tmp}.
#
# Exit codes:
#   0: all checks passed
#   1: at least one check reported drift
#   2: at least one check had a setup error (or no checks discovered)
#
# Usage:
#   bash tools/adr-verify/runner.sh
#   bash tools/adr-verify/runner.sh --check h-01-agent-memory-layout
#   CHECK_FILTER=h-01-agent-memory-layout,h-02-drift-checks-wired bash tools/adr-verify/runner.sh

set -uo pipefail

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
CHECKS_DIR="$SELF_DIR/checks"

REPO_ROOT="${REPO_ROOT:-$(git -C "$SELF_DIR" rev-parse --show-toplevel 2>/dev/null)}"
if [[ -z "$REPO_ROOT" || ! -d "$REPO_ROOT" ]]; then
  echo "ERROR: could not resolve REPO_ROOT (set it explicitly or run inside a git checkout)" >&2
  exit 2
fi

CHECK_FILTER="${CHECK_FILTER:-}"
RESULTS_FILE="${ADR_DRIFT_RESULTS_FILE:-$(mktemp "${TMPDIR:-/tmp}/adr-drift-results.XXXXXX")}"

if [[ "${1:-}" == "--check" && -n "${2:-}" ]]; then
  CHECK_FILTER="$2"
fi

mkdir -p "$(dirname "$RESULTS_FILE")"
{
  echo "## ADR Drift Detection Results"
  echo ""
  echo "_Generated $(date -u +'%Y-%m-%dT%H:%M:%SZ') by tools/adr-verify/runner.sh_"
  echo "_Repo: ${REPO_ROOT}_"
  echo ""
  echo "---"
  echo ""
} > "$RESULTS_FILE"

declare -a checks_to_run=()
while IFS= read -r -d '' check_path; do
  name="$(basename "$check_path" .sh)"
  if [[ -n "$CHECK_FILTER" ]]; then
    if [[ ",$CHECK_FILTER," == *",$name,"* ]]; then
      checks_to_run+=("$check_path")
    fi
  else
    checks_to_run+=("$check_path")
  fi
done < <(find "$CHECKS_DIR" -maxdepth 1 -name '*.sh' -type f -print0 | sort -z)

if [[ ${#checks_to_run[@]} -eq 0 ]]; then
  echo "ERROR: no checks discovered under $CHECKS_DIR (filter: '$CHECK_FILTER')" >&2
  exit 2
fi

total_pass=0
total_drift=0
total_setup_err=0

for check_path in "${checks_to_run[@]}"; do
  name="$(basename "$check_path" .sh)"
  adr_id="$(grep -m1 -E '^# ADR:' "$check_path" | sed -E 's/^# ADR: *//')"
  # Harness defaults carry their own prefix (H-1); project ADRs are bare numbers.
  if [[ "$adr_id" =~ ^[0-9]+$ ]]; then adr_label="ADR-$adr_id"; else adr_label="${adr_id:-ADR-?}"; fi
  asserts="$(grep -m1 -E '^# Asserts:' "$check_path" | sed -E 's/^# Asserts: *//')"

  echo "▶ $name ($adr_label)"

  # Run in subshell so a stray `exit` inside a check can't kill the runner
  out="$(
    REPO_ROOT="$REPO_ROOT" \
    ADR_DRIFT_RESULTS_FILE="$RESULTS_FILE" \
    ADR_CHECK_NAME="$name" \
    ADR_CHECK_ID="$adr_id" \
    ADR_CHECK_ASSERTS="$asserts" \
    bash "$check_path" 2>&1
  )"
  exit_code=$?

  case "$exit_code" in
    0)
      total_pass=$((total_pass + 1))
      {
        echo "- **PASS** \`$name\`: $adr_label: $asserts"
        if [[ -n "$out" ]]; then
          echo "  <details><summary>notes</summary>"
          echo ""
          echo '  ```'
          printf '%s\n' "$out" | sed 's/^/  /'
          echo '  ```'
          echo "  </details>"
        fi
      } >> "$RESULTS_FILE"
      ;;
    1)
      total_drift=$((total_drift + 1))
      {
        echo "- **DRIFT** \`$name\`: $adr_label: $asserts"
        if [[ -n "$out" ]]; then
          echo "  <details><summary>details</summary>"
          echo ""
          echo '  ```'
          printf '%s\n' "$out" | sed 's/^/  /'
          echo '  ```'
          echo "  </details>"
        fi
      } >> "$RESULTS_FILE"
      ;;
    *)
      total_setup_err=$((total_setup_err + 1))
      {
        echo "- **SETUP ERROR** \`$name\` (exit $exit_code): $adr_label: $asserts"
        if [[ -n "$out" ]]; then
          echo "  <details><summary>details</summary>"
          echo ""
          echo '  ```'
          printf '%s\n' "$out" | sed 's/^/  /'
          echo '  ```'
          echo "  </details>"
        fi
      } >> "$RESULTS_FILE"
      ;;
  esac
done

{
  echo ""
  echo "---"
  echo ""
  echo "### Summary"
  echo ""
  echo "| Status | Count |"
  echo "|--------|-------|"
  echo "| Passed | $total_pass |"
  echo "| Drifted | $total_drift |"
  echo "| Setup errors | $total_setup_err |"
} >> "$RESULTS_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Summary: $total_pass passed, $total_drift drift, $total_setup_err setup errors"
echo "Results: $RESULTS_FILE"
echo "═══════════════════════════════════════════════════════════"

if [[ $total_setup_err -gt 0 ]]; then
  exit 2
fi
if [[ $total_drift -gt 0 ]]; then
  exit 1
fi
exit 0

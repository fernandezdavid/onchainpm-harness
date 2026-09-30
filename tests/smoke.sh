#!/usr/bin/env bash
# End-to-end smoke test for the harness. Uses only temporary folders.
# It never touches the real home folder or any existing project.
set -uo pipefail

HARNESS="$(cd "$(dirname "$0")/.." && pwd -P)"
TMP="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
ok()  { echo "PASS  $1"; pass=$((pass + 1)); }
bad() { echo "FAIL  $1"; fail=$((fail + 1)); }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; } # check <label> <shell test>
expect_exit() { # expect_exit <code> <label> <command...>
  local want="$1" label="$2"; shift 2
  "$@" >"$TMP/last.log" 2>&1
  local got=$?
  if [ "$got" = "$want" ]; then ok "$label"; else bad "$label (exit $got, want $want)"; sed 's/^/      /' "$TMP/last.log"; fi
}
fill_slots() { # remove every TODO(bootstrap) line under <dir>
  grep -rlF 'TODO(bootstrap)' "$1" --exclude=BOOTSTRAP.md --exclude=ADOPT.md --exclude=check-bootstrap.sh --exclude-dir=.git --exclude-dir=.harness |
    while IFS= read -r f; do sed -i.bak '/TODO(bootstrap)/d' "$f" && rm -f "$f.bak"; done
}

export ADR_DRIFT_RESULTS_FILE="$TMP/adr-drift.md"

echo "== bin/new-project"
P="$TMP/demo"
expect_exit 0 "creates a project" bash "$HARNESS/bin/new-project" "$P" "Demo & Co"
expect_exit 1 "refuses a non-empty target" bash "$HARNESS/bin/new-project" "$P"
expect_exit 1 "refuses a project name with a line break" bash "$HARNESS/bin/new-project" "$TMP/newline" $'bad\nname'
check "leaves nothing behind after a refused name" '[ ! -e "$TMP/newline" ]'
check "fills the project name everywhere" '! grep -rqF "{{PROJECT_NAME}}" "$P"'
check "keeps sed special characters in the name" 'grep -qF "Demo & Co" "$P/AGENTS.md"'
check "records .harness-version" '[ -s "$P/.harness-version" ]'
check "initialises a git repository" '[ -d "$P/.git" ]'
check "does not copy ADOPT.md" '[ ! -e "$P/ADOPT.md" ]'

echo "== checks on a new project"
expect_exit 0 "memory budgets pass" bash "$P/scripts/check-agent-memory.sh"
expect_exit 0 "drift checks pass" bash "$P/tools/adr-verify/runner.sh"
check "drift report labels harness defaults as H-n" 'grep -qF "H-1:" "$ADR_DRIFT_RESULTS_FILE"'
expect_exit 1 "setup check fails while slots are open" bash "$P/scripts/check-bootstrap.sh"
fill_slots "$P"
expect_exit 0 "setup check passes when slots are filled" bash "$P/scripts/check-bootstrap.sh"

echo "== each check catches what it claims"
mkdir -p "$P/area"
for i in $(seq 1 120); do echo "line $i"; done > "$P/area/AGENTS.md"
expect_exit 1 "memory check fails on a nested file over budget" bash "$P/scripts/check-agent-memory.sh"
mkdir -p "$P/dist"
for i in $(seq 1 120); do echo "line $i"; done > "$P/dist/AGENTS.md"
printf '# Area\n' > "$P/area/AGENTS.md"
expect_exit 0 "memory check skips build output (dist/)" bash "$P/scripts/check-agent-memory.sh"
printf '# no import here\n' > "$P/dist/CLAUDE.md"
expect_exit 0 "H-1 check skips build output (dist/)" bash "$P/tools/adr-verify/runner.sh" --check h-01-agent-memory-layout
printf '# no import here\n' > "$P/area/CLAUDE.md"
expect_exit 1 "H-1 check catches a CLAUDE.md without @AGENTS.md" bash "$P/tools/adr-verify/runner.sh" --check h-01-agent-memory-layout
printf '@AGENTS.md\n' > "$P/area/CLAUDE.md"
expect_exit 0 "H-1 check passes once the import is back" bash "$P/tools/adr-verify/runner.sh" --check h-01-agent-memory-layout
printf '#!/usr/bin/env bash\nexit 0\n' > "$P/tools/adr-verify/checks/adr-99-no-headers.sh"
expect_exit 1 "H-2 check catches a check without headers" bash "$P/tools/adr-verify/runner.sh" --check h-02-drift-checks-wired
rm "$P/tools/adr-verify/checks/adr-99-no-headers.sh"

echo "== bin/adopt"
E="$TMP/existing"
mkdir -p "$E/src" "$E/.github/workflows"
printf '# Old rules\n\n- Use tabs.\n' > "$E/AGENTS.md"
for i in $(seq 1 60); do echo "Claude rule $i"; done > "$E/CLAUDE.md"
printf 'node_modules/\n' > "$E/.gitignore"
printf 'name: Existing CI\n' > "$E/.github/workflows/ci.yml"
printf 'console.log("app")\n' > "$E/src/app.js"
printf 'a file where the template has a folder\n' > "$E/tools"
git -C "$E" init -q -b main
git -C "$E" -c user.email=t@example.com -c user.name=T add -A
git -C "$E" -c user.email=t@example.com -c user.name=T commit -q -m "existing project"
mkdir -p "$TMP/snapshot" && cp -R "$E/." "$TMP/snapshot/" && rm -rf "$TMP/snapshot/.git"

expect_exit 1 "refuses a folder that is not a git repository" bash "$HARNESS/bin/adopt" "$TMP/demo/area"
echo "wip" > "$E/wip.txt"
expect_exit 1 "refuses a working tree with changes" bash "$HARNESS/bin/adopt" "$E"
check "a refused adopt creates no branch" '! git -C "$E" show-ref --verify --quiet refs/heads/harness/adopt'
check "a refused adopt adds no files" '[ ! -e "$E/ADOPT.md" ] && [ ! -e "$E/.harness" ]'
rm "$E/wip.txt"

expect_exit 0 "adopts into a clean existing project" bash "$HARNESS/bin/adopt" "$E" "Existing App"
check "works on the branch harness/adopt" '[ "$(git -C "$E" branch --show-current)" = harness/adopt ]'
check "changes no file the project had" 'for f in AGENTS.md CLAUDE.md .gitignore .github/workflows/ci.yml src/app.js tools; do cmp -s "$E/$f" "$TMP/snapshot/$f" || exit 1; done'
check "stages clashing files in .harness/incoming/" '[ -f "$E/.harness/incoming/AGENTS.md" ] && [ -f "$E/.harness/incoming/.gitignore" ] && [ -f "$E/.harness/incoming/CLAUDE.md" ]'
check "stages files whose parent path is a file" '[ -f "$E/.harness/incoming/tools/adr-verify/runner.sh" ]'
check "adds missing harness files" '[ -f "$E/docs/engineering/decisions.md" ] && [ -f "$E/scripts/check-bootstrap.sh" ] && [ -f "$E/.github/workflows/adr-drift-check.yml" ]'
check "adds ADOPT.md, not BOOTSTRAP.md" '[ -f "$E/ADOPT.md" ] && [ ! -e "$E/BOOTSTRAP.md" ]'
check "adds harness.yml beside the existing CI" '[ -f "$E/.github/workflows/harness.yml" ] && [ ! -e "$E/.harness/incoming/.github/workflows/ci.yml" ]'
check "fills the project name" 'grep -qF "Existing App" "$E/STRATEGY.md" && ! grep -rqF "{{PROJECT_NAME}}" "$E" --exclude-dir=.git'
expect_exit 1 "setup check fails while files are staged" bash "$E/scripts/check-bootstrap.sh"
expect_exit 1 "refuses to adopt twice" bash "$HARNESS/bin/adopt" "$E"

# A copy that fails after the branch exists must put everything back
if [ "$(id -u)" != 0 ]; then
  F="$TMP/failing"
  mkdir -p "$F/docs"
  printf 'notes\n' > "$F/docs/notes.md"
  git -C "$F" init -q -b main
  git -C "$F" -c user.email=t@example.com -c user.name=T add -A
  git -C "$F" -c user.email=t@example.com -c user.name=T commit -q -m "existing project"
  chmod 555 "$F/docs"
  expect_exit 1 "a copy that fails mid-apply exits with an error" bash "$HARNESS/bin/adopt" "$F"
  chmod 755 "$F/docs"
  check "a failed apply returns to the original branch" '[ "$(git -C "$F" branch --show-current)" = main ]'
  check "a failed apply deletes the harness/adopt branch" '! git -C "$F" show-ref --verify --quiet refs/heads/harness/adopt'
  check "a failed apply leaves no file behind" '[ -z "$(git -C "$F" status --porcelain --ignored)" ]'
else
  echo "SKIP  mid-apply failure (running as root, so permissions cannot force a failure)"
fi

# Simulate the agent finishing ADOPT.md
rm "$E/tools" && mv "$E/.harness/incoming/tools" "$E/tools"
{ cat "$E/.harness/incoming/AGENTS.md"; printf '\n## Project rules\n\n- Use tabs.\n'; } > "$E/AGENTS.md"
printf '# CLAUDE.md\n\n@AGENTS.md\n' > "$E/CLAUDE.md"
cat "$E/.harness/incoming/.gitignore" >> "$E/.gitignore"
rm -rf "$E/.harness"
fill_slots "$E"
rm "$E/ADOPT.md"
expect_exit 0 "memory budgets pass after adoption" bash "$E/scripts/check-agent-memory.sh"
expect_exit 0 "drift checks pass after adoption" bash "$E/tools/adr-verify/runner.sh"
expect_exit 0 "setup check passes after adoption" bash "$E/scripts/check-bootstrap.sh"

echo "== global/install.sh, against a fake home and a copy of global/"
G="$TMP/harness-copy/global"
mkdir -p "$G"
cp "$HARNESS/global/AGENTS.md" "$HARNESS/global/install.sh" "$G/"
printf '## Private rules\n\n- private-marker-42\n' > "$G/AGENTS.local.md"
INSTALL="$G/install.sh"
H="$TMP/home"
mkdir -p "$H/.claude" "$H/.codex" "$H/.agents"
: > "$H/.codex/AGENTS.md"
echo "old rules" > "$H/.claude/CLAUDE.md"
echo "a file the user wrote" > "$H/.agents/AGENTS.md"
expect_exit 2 "rejects an unknown flag" env HOME="$H" bash "$INSTALL" --dryrun
check "a rejected flag changes nothing" '[ "$(cat "$H/.claude/CLAUDE.md")" = "old rules" ] && [ "$(cat "$H/.agents/AGENTS.md")" = "a file the user wrote" ]'
expect_exit 0 "dry run exits cleanly" env HOME="$H" bash "$INSTALL" --dry-run
check "dry run changes nothing" '[ "$(cat "$H/.claude/CLAUDE.md")" = "old rules" ] && [ "$(cat "$H/.agents/AGENTS.md")" = "a file the user wrote" ] && [ ! -L "$H/.codex/AGENTS.md" ]'
expect_exit 0 "installs" env HOME="$H" bash "$INSTALL"
check "generates ~/.agents/AGENTS.md from the public rules" 'head -1 "$H/.agents/AGENTS.md" | grep -qF "Generated by onchainpm-harness" && grep -qF "# Personal agent rules" "$H/.agents/AGENTS.md"'
check "appends the private rules" 'grep -qF "private-marker-42" "$H/.agents/AGENTS.md"'
check "links Codex to ~/.agents/AGENTS.md" '[ "$(readlink "$H/.codex/AGENTS.md")" = "$H/.agents/AGENTS.md" ]'
check "links Gemini to ~/.agents/AGENTS.md" '[ "$(readlink "$H/.gemini/GEMINI.md")" = "$H/.agents/AGENTS.md" ]'
check "makes Claude import ~/.agents/AGENTS.md" 'grep -qxF "@~/.agents/AGENTS.md" "$H/.claude/CLAUDE.md"'
check "backs up every replaced file, empty ones too" 'ls "$H/.claude/"CLAUDE.md.bak.* "$H/.codex/"AGENTS.md.bak.* "$H/.agents/"AGENTS.md.bak.* >/dev/null 2>&1'
env HOME="$H" bash "$INSTALL" >"$TMP/rerun.log" 2>&1
check "is a no-op on re-run" '! grep -qE "^(link|write|backup)" "$TMP/rerun.log"'
echo "- a new public rule" >> "$G/AGENTS.md"
sleep 1
env HOME="$H" bash "$INSTALL" >"$TMP/update.log" 2>&1
check "updates the generated file after an edit" 'grep -qF "a new public rule" "$H/.agents/AGENTS.md" && grep -q "^write   $H/.agents/AGENTS.md" "$TMP/update.log"'
check "does not back up its own generated file" '[ "$(ls "$H/.agents/"AGENTS.md.bak.* | wc -l | tr -d " ")" = 1 ]'
expect_exit 0 "uninstalls" env HOME="$H" bash "$INSTALL" --uninstall
check "uninstall restores CLAUDE.md" '[ "$(cat "$H/.claude/CLAUDE.md")" = "old rules" ]'
check "uninstall restores the Codex file" '[ -f "$H/.codex/AGENTS.md" ] && [ ! -L "$H/.codex/AGENTS.md" ] && [ ! -s "$H/.codex/AGENTS.md" ]'
check "uninstall restores the user file at ~/.agents/AGENTS.md" '[ "$(cat "$H/.agents/AGENTS.md")" = "a file the user wrote" ]'
check "uninstall removes the Gemini link it made" '[ ! -e "$H/.gemini/GEMINI.md" ]'

echo "== house rules for the harness itself"
FILES="$TMP/files.txt"
git -C "$HARNESS" ls-files --cached --others --exclude-standard > "$FILES"
check "the private rules file is ignored by git" 'git -C "$HARNESS" check-ignore -q global/AGENTS.local.md'
check "published files hold no email address" '! (cd "$HARNESS" && tr "\n" "\0" < "$FILES" | xargs -0 grep -hoE "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}" 2>/dev/null | grep -vE "@example\.com$|noreply|\.md$" | grep -q .)'
check "published files name no private workspace or server" '! (cd "$HARNESS" && grep -v "^tests/smoke.sh$" "$FILES" | tr "\n" "\0" | xargs -0 grep -liE "robotmoney|tntlabs|chainflip|linear-rm|linear-personal" 2>/dev/null | grep -q .)'
check "no em dashes in tracked or new files" '! (cd "$HARNESS" && tr "\n" "\0" < "$FILES" | xargs -0 grep -ln $'"'"'\xe2\x80\x94'"'"' 2>/dev/null | grep -q .)'
check "template and adopt name no product or workspace" '! grep -rniE "fire your coach|fireyourcoach|robot ?money|robotmoney|\bFYC\b|OCPM|tntlabs" "$HARNESS/template" "$HARNESS/adopt"'
check "the decision log numbers project decisions from ADR-1" 'grep -qF "Project decisions, \`ADR-1\` onward" "$HARNESS/template/docs/engineering/decisions.md" && ! grep -qE "Project decisions, \`H-" "$HARNESS/template/docs/engineering/decisions.md"'
check "template cross-references to defaults use H- IDs" '! grep -rnE "\(ADR-[0-9]+\)" "$HARNESS/template" "$HARNESS/adopt"'
missing=""
while IFS= read -r f; do
  rel="${f#"$HARNESS/template/"}"
  grep -qF "$rel" "$HARNESS/template/BOOTSTRAP.md" || missing="$missing BOOTSTRAP.md:$rel"
  [ "$rel" = .github/workflows/ci.yml ] && continue
  grep -qF "$rel" "$HARNESS/adopt/ADOPT.md" || missing="$missing ADOPT.md:$rel"
done < <(grep -rlF 'TODO(bootstrap)' "$HARNESS/template" --exclude=BOOTSTRAP.md --exclude=check-bootstrap.sh)
if [ -z "$missing" ]; then ok "every file with a slot is named in BOOTSTRAP.md and ADOPT.md"; else bad "every file with a slot is named in BOOTSTRAP.md and ADOPT.md:$missing"; fi
lines=$(awk 'END { print NR }' "$HARNESS/global/AGENTS.md")
check "global/AGENTS.md within 150 lines ($lines)" '[ "$lines" -le 150 ]'

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

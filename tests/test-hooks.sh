#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_ROOT="${ROOT}/plugins/coding-discipline"
HOOK="${PLUGIN_ROOT}/hooks/session-start-skills"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/coding-discipline-tests.XXXXXX")"

# A candidate interpreter must actually run. On Windows, the Microsoft Store
# python3.exe stub passes command -v but exits 49 when invoked; `py` is the
# launcher a real Windows install provides, so it has to be a candidate too or
# this suite is unrunnable on the Git Bash setup the README tells people to use.
PYTHON=
for cand in python3 python py; do
  if "$cand" -c '' >/dev/null 2>&1; then PYTHON="$cand"; break; fi
done
if [ -z "$PYTHON" ]; then
  printf 'FAIL: Python is required for JSON validation\n' >&2
  exit 1
fi

cleanup() {
  case "$TMP_ROOT" in
    "${TMPDIR:-/tmp}"/coding-discipline-tests.*) rm -rf -- "$TMP_ROOT" ;;
    *) printf 'refusing to remove unexpected test path: %s\n' "$TMP_ROOT" >&2 ;;
  esac
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

make_repo() {
  local path="$1"
  git init -q "$path"
  git -C "$path" -c user.name=tests -c user.email=tests@example.com \
    commit --allow-empty -qm initial
}

assert_json_output() {
  "$PYTHON" -c 'import json,sys; payload=json.load(sys.stdin); assert payload["hookSpecificOutput"]["hookEventName"] == "SessionStart"'
}

# Codex's documented PLUGIN_ROOT wins even when CODEX_HOME is unset and the
# compatibility CLAUDE_PLUGIN_ROOT is also present.
repo_codex="${TMP_ROOT}/repo-codex"
make_repo "$repo_codex"
output="$({
  cd "$repo_codex"
  env -u CODEX_HOME \
    PLUGIN_ROOT="$PLUGIN_ROOT" \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT" \
    CD_USAGE_LOG="${TMP_ROOT}/usage-codex.jsonl" \
    "$HOOK"
})"
printf '%s\n' "$output" | assert_json_output
[ -f "${repo_codex}/AGENTS.md" ] || fail 'Codex did not create AGENTS.md'
[ ! -e "${repo_codex}/CLAUDE.md" ] || fail 'Codex created CLAUDE.md'
grep -q '^# Project guide$' "${repo_codex}/AGENTS.md" \
  || fail 'Codex did not seed the English project guide'
grep -q '"platform":"codex"' "${TMP_ROOT}/usage-codex.jsonl" \
  || fail 'Codex usage record has the wrong platform'

# A Claude guide must not prevent Codex from creating its own guide.
printf '# Claude guide\n' > "${repo_codex}/CLAUDE.md"
rm "${repo_codex}/AGENTS.md"
(
  cd "$repo_codex"
  CD_USAGE_ENABLED=0 "$HOOK" codex >/dev/null
)
[ -f "${repo_codex}/AGENTS.md" ] || fail 'CLAUDE.md blocked AGENTS.md creation'

# Existing target guides are never overwritten.
printf '# Keep me\n' > "${repo_codex}/AGENTS.md"
(
  cd "$repo_codex"
  CD_USAGE_ENABLED=0 "$HOOK" codex >/dev/null
)
[ "$(cat "${repo_codex}/AGENTS.md")" = '# Keep me' ] || fail 'existing AGENTS.md was overwritten'

# Starting in a nested directory still seeds the repository root.
repo_nested="${TMP_ROOT}/repo-nested"
make_repo "$repo_nested"
mkdir -p "${repo_nested}/src/nested"
(
  cd "${repo_nested}/src/nested"
  CD_USAGE_ENABLED=0 "$HOOK" codex >/dev/null
)
[ -f "${repo_nested}/AGENTS.md" ] || fail 'nested start did not seed the repository root'
[ ! -e "${repo_nested}/src/nested/AGENTS.md" ] || fail 'guide was written into a nested directory'

# Git worktrees use a .git pointer file and must still be recognized.
repo_main="${TMP_ROOT}/repo-main"
repo_worktree="${TMP_ROOT}/repo-worktree"
make_repo "$repo_main"
git -C "$repo_main" worktree add -qb test-worktree "$repo_worktree"
(
  cd "$repo_worktree"
  CD_USAGE_ENABLED=0 "$HOOK" codex >/dev/null
)
[ -f "${repo_worktree}/AGENTS.md" ] || fail 'worktree did not receive AGENTS.md'

# Claude Code still receives CLAUDE.md.
repo_claude="${TMP_ROOT}/repo-claude"
make_repo "$repo_claude"
(
  cd "$repo_claude"
  CD_USAGE_ENABLED=0 "$HOOK" claude-code >/dev/null
)
[ -f "${repo_claude}/CLAUDE.md" ] || fail 'Claude Code did not create CLAUDE.md'
[ ! -e "${repo_claude}/AGENTS.md" ] || fail 'Claude Code created AGENTS.md'
grep -q '^# Project guide$' "${repo_claude}/CLAUDE.md" \
  || fail 'Claude Code did not seed the English project guide'

# Both optional side effects can be disabled.
repo_opt_out="${TMP_ROOT}/repo-opt-out"
make_repo "$repo_opt_out"
(
  cd "$repo_opt_out"
  CD_SEED_AGENT_DOC=0 CD_USAGE_ENABLED=0 CD_USAGE_LOG="${TMP_ROOT}/disabled.jsonl" \
    "$HOOK" codex >/dev/null
)
[ ! -e "${repo_opt_out}/AGENTS.md" ] || fail 'guide opt-out was ignored'
[ ! -e "${TMP_ROOT}/disabled.jsonl" ] || fail 'usage opt-out was ignored'

# Cursor and Copilot read the primer from different envelope fields than Claude
# Code and Codex. The hook already handles all four; these cases keep a refactor
# from silently dropping the two that no maintainer runs day to day.
assert_no_guide() {
  local repo="$1" host="$2"
  [ ! -e "${repo}/AGENTS.md" ] || fail "${host} seeded AGENTS.md"
  [ ! -e "${repo}/CLAUDE.md" ] || fail "${host} seeded CLAUDE.md"
}

repo_cursor="${TMP_ROOT}/repo-cursor"
make_repo "$repo_cursor"
output="$({
  cd "$repo_cursor"
  env -u CODEX_HOME -u PLUGIN_ROOT -u COPILOT_CLI \
    CURSOR_PLUGIN_ROOT="$PLUGIN_ROOT" \
    CD_USAGE_LOG="${TMP_ROOT}/usage-cursor.jsonl" \
    "$HOOK" cursor
})"
printf '%s\n' "$output" | "$PYTHON" -c 'import json,sys; p=json.load(sys.stdin); assert set(p) == {"additional_context"}, p; assert p["additional_context"].strip()' \
  || fail 'Cursor did not receive additional_context'
grep -q '"platform":"cursor"' "${TMP_ROOT}/usage-cursor.jsonl" \
  || fail 'Cursor usage record has the wrong platform'
assert_no_guide "$repo_cursor" Cursor

repo_copilot="${TMP_ROOT}/repo-copilot"
make_repo "$repo_copilot"
output="$({
  cd "$repo_copilot"
  env -u CODEX_HOME -u PLUGIN_ROOT -u CURSOR_PLUGIN_ROOT \
    COPILOT_CLI=1 \
    CD_USAGE_LOG="${TMP_ROOT}/usage-copilot.jsonl" \
    "$HOOK" copilot
})"
printf '%s\n' "$output" | "$PYTHON" -c 'import json,sys; p=json.load(sys.stdin); assert set(p) == {"additionalContext"}, p; assert p["additionalContext"].strip()' \
  || fail 'Copilot did not receive additionalContext'
grep -q '"platform":"copilot"' "${TMP_ROOT}/usage-copilot.jsonl" \
  || fail 'Copilot usage record has the wrong platform'
assert_no_guide "$repo_copilot" Copilot

# Hosts outside the two first-class ones must get the neutral invocation note
# rather than Claude Code's Skill-tool wording.
case "$output" in
  *'Load skills through the skill mechanism of this host'*) ;;
  *) fail 'a non-primary host did not receive the neutral invocation note' ;;
esac
case "$output" in
  *'Skill tool'*) fail 'a non-primary host received Claude Code wording' ;;
esac

printf 'hook behavior tests passed\n'

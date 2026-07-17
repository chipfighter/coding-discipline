#!/usr/bin/env bash
# Summarize usage written by SessionStart (session activations on every host)
# and PostToolUse(Skill) (per-skill activity on Claude Code). No jq required.
# Usage:
#   bash skills-count.sh            # all records
#   bash skills-count.sh <keyword>  # records whose full line contains keyword
PATH="/usr/bin:/mingw64/bin:${PATH:-}"
export PATH
set -euo pipefail

LOG="${CD_USAGE_LOG:-$HOME/.coding-discipline/usage.jsonl}"
[ -f "$LOG" ] || { echo "No usage records yet ($LOG does not exist)."; exit 0; }

filter="${1:-}"
if [ -n "$filter" ]; then
  data="$(grep -F "$filter" "$LOG" || true)"
  echo "== Usage (records containing '$filter') =="
else
  data="$(cat "$LOG")"
  echo "== Usage (all records) =="
fi
[ -n "$data" ] || { echo "(No matching records.)"; exit 0; }

field() { grep -o "\"$1\":\"[^\"]*\"" | sed -E 's/.*:"([^"]*)"/\1/'; }

echo ""
echo "-- Session activations by host --"
sess="$(printf '%s\n' "$data" | grep '"event":"session"' || true)"
if [ -n "$sess" ]; then printf '%s\n' "$sess" | field platform | sort | uniq -c | sort -rn
else echo "(None yet.)"; fi

echo ""
echo "-- Skill invocations by skill (Claude Code only) --"
sk="$(printf '%s\n' "$data" | grep '"event":"skill"' || true)"
if [ -n "$sk" ]; then printf '%s\n' "$sk" | field skill | sort | uniq -c | sort -rn
else echo "(None yet; only Claude Code exposes per-skill activity.)"; fi

echo ""
total="$(printf '%s\n' "$data" | grep -c '' || true)"
first="$(printf '%s\n' "$data" | head -1 | field ts)"
last="$(printf '%s\n' "$data" | tail -1 | field ts)"
echo "${total} total records; first ${first}; latest ${last}"

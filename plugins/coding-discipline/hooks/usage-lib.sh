#!/usr/bin/env bash
# Shared cross-platform usage library sourced by session-start-skills and
# log-usage. Pure bash, no jq.
# Every host appends to the same JSONL sink; environment variables identify the
# host. Record shape: {"ts","platform","event":"session"|"skill","skill","cwd"}

PATH="/usr/bin:/mingw64/bin:${PATH:-}"
export PATH

CD_USAGE_LOG="${CD_USAGE_LOG:-$HOME/.coding-discipline/usage.jsonl}"
CD_USAGE_ENABLED="${CD_USAGE_ENABLED:-1}"

# Detect the host from runtime environment variables, most specific first.
cd_detect_platform() {
  if   [ -n "${CD_PLATFORM:-}" ]; then echo "$CD_PLATFORM"
  elif [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then echo cursor
  elif [ -n "${PLUGIN_ROOT:-}" ];        then echo codex
  elif [ -n "${CODEX_HOME:-}" ];         then echo codex
  elif [ -n "${COPILOT_CLI:-}" ];        then echo copilot
  elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] || [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then echo claude-code
  else echo unknown
  fi
}

# cd_write_record <event> <skill> <cwd>
# skill may be empty; every failure stays silent and never interrupts work.
cd_write_record() {
  local event="${1:-}" skill="${2:-}" cwd="${3:-}"
  local platform ts
  case "$CD_USAGE_ENABLED" in
    0|false|False|FALSE|no|No|NO|off|Off|OFF) return 0 ;;
  esac
  platform="$(cd_detect_platform)"
  ts="$(date -u +%FT%TZ 2>/dev/null || echo '?')"
  # JSON safety: normalize Windows backslashes to readable forward slashes,
  # then escape any remaining quotes.
  cwd="${cwd//\\//}"; cwd="${cwd//\"/\\\"}"
  skill="${skill//\"/\\\"}"
  mkdir -p "$(dirname "$CD_USAGE_LOG")" 2>/dev/null || true
  printf '{"ts":"%s","platform":"%s","event":"%s","skill":"%s","cwd":"%s"}\n' \
    "$ts" "$platform" "$event" "$skill" "$cwd" >> "$CD_USAGE_LOG" 2>/dev/null || true
}

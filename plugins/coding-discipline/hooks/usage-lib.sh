#!/usr/bin/env bash
# 共享用量库（被 session-start-skills 和 log-usage source）。纯 bash，无 jq，跨平台。
# 统一水槽：所有平台的用量记录都追加到同一个 JSONL；平台靠环境变量识别。
# 记录形状：{"ts","platform","event":"session"|"skill","skill","cwd"}

CD_USAGE_LOG="${CD_USAGE_LOG:-$HOME/.coding-discipline/usage.jsonl}"

# 按运行时环境变量识别平台（各平台各设各的；最具体的先判）。
cd_detect_platform() {
  if   [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then echo cursor
  elif [ -n "${CODEX_HOME:-}" ];         then echo codex
  elif [ -n "${COPILOT_CLI:-}" ];        then echo copilot
  elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] || [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then echo claude-code
  else echo unknown
  fi
}

# cd_write_record <event> <skill> <cwd>   （skill 可空；任何失败都不报错、不打断主流程）
cd_write_record() {
  local event="${1:-}" skill="${2:-}" cwd="${3:-}"
  local platform ts
  platform="$(cd_detect_platform)"
  ts="$(date -u +%FT%TZ 2>/dev/null || echo '?')"
  # JSON 安全：Windows 反斜杠转正斜杠（免转义、更好读），再转义残留引号。
  cwd="${cwd//\\//}"; cwd="${cwd//\"/\\\"}"
  skill="${skill//\"/\\\"}"
  mkdir -p "$(dirname "$CD_USAGE_LOG")" 2>/dev/null || true
  printf '{"ts":"%s","platform":"%s","event":"%s","skill":"%s","cwd":"%s"}\n' \
    "$ts" "$platform" "$event" "$skill" "$cwd" >> "$CD_USAGE_LOG" 2>/dev/null || true
}

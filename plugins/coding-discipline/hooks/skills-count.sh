#!/usr/bin/env bash
# 汇总用量。数据由 SessionStart（会话激活·各平台）与 PostToolUse(Skill)（按 skill·Claude Code）写入。无 jq。
# 用法：
#   bash skills-count.sh            # 全部
#   bash skills-count.sh <关键词>   # 只看整行含关键词的记录（cwd 在其中，如 HuiNeng）
PATH="/usr/bin:/mingw64/bin:${PATH:-}"
export PATH
set -euo pipefail

LOG="${CD_USAGE_LOG:-$HOME/.coding-discipline/usage.jsonl}"
[ -f "$LOG" ] || { echo "还没有用量记录（$LOG 不存在）。"; exit 0; }

filter="${1:-}"
if [ -n "$filter" ]; then
  data="$(grep -F "$filter" "$LOG" || true)"
  echo "== 用量（仅含 '$filter' 的记录）=="
else
  data="$(cat "$LOG")"
  echo "== 用量（全部）=="
fi
[ -n "$data" ] || { echo "（无匹配记录）"; exit 0; }

field() { grep -o "\"$1\":\"[^\"]*\"" | sed -E 's/.*:"([^"]*)"/\1/'; }

echo ""
echo "-- 会话激活次数（按平台 · 各平台通用）--"
sess="$(printf '%s\n' "$data" | grep '"event":"session"' || true)"
if [ -n "$sess" ]; then printf '%s\n' "$sess" | field platform | sort | uniq -c | sort -rn
else echo "（暂无）"; fi

echo ""
echo "-- skill 调用次数（Claude Code · 按 skill）--"
sk="$(printf '%s\n' "$data" | grep '"event":"skill"' || true)"
if [ -n "$sk" ]; then printf '%s\n' "$sk" | field skill | sort | uniq -c | sort -rn
else echo "（暂无——只有 Claude Code 会产生按-skill 明细）"; fi

echo ""
total="$(printf '%s\n' "$data" | grep -c '' || true)"
first="$(printf '%s\n' "$data" | head -1 | field ts)"
last="$(printf '%s\n' "$data" | tail -1 | field ts)"
echo "总记录 ${total} 条；最早 ${first}；最近 ${last}"

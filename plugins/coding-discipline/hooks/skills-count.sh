#!/usr/bin/env bash
# 汇总 skill 调用次数。数据由 PostToolUse(Skill) 钩子 log-skill-usage 写入。**不依赖 jq**。
# 用法：
#   bash skills-count.sh            # 全部
#   bash skills-count.sh <关键词>   # 只看整行含关键词的记录（cwd 在其中，如 HuiNeng）
set -euo pipefail

LOG="$HOME/.claude/skill-usage.jsonl"
[ -f "$LOG" ] || { echo "还没有 skill 调用记录（$LOG 不存在）。"; exit 0; }

filter="${1:-}"
if [ -n "$filter" ]; then
  data="$(grep -F "$filter" "$LOG" || true)"
  echo "== skill 调用次数（仅含 '$filter' 的记录）=="
else
  data="$(cat "$LOG")"
  echo "== skill 调用次数（全部项目）=="
fi

[ -n "$data" ] || { echo "（无匹配记录）"; exit 0; }

# 抽每行的 "skill":"xxx" / "ts":"xxx"
val() { grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed -E 's/.*"([^"]*)"$/\1/'; }

printf '%s\n' "$data" | val skill | sort | uniq -c | sort -rn

total="$(printf '%s\n' "$data" | grep -c '' || true)"
first="$(printf '%s\n' "$data" | head -1 | val ts)"
last="$(printf '%s\n' "$data" | tail -1 | val ts)"
echo "---"
echo "总调用 ${total} 次；最早 ${first}；最近 ${last}"

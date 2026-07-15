# 触发契约场景集

v0.6.0（触发重校准）的验收物：给定一批任务描述，核对各 skill「该触发的触发了、不该触发的没触发」。
场景在 [scenarios.md](scenarios.md)，每个场景 = 任务描述（原样发给助手的话）+ 期望触发集 + 期望不触发集。

## 怎么跑

1. 装好本插件，**新开一个干净 session**（Claude Code 和 Codex 各跑一遍；场景之间不共享 session，避免上下文互相污染）。
2. 把场景的「任务描述」原样发给助手，正常交互到任务收尾。
3. 按平台记录结果：
   - **Claude Code**：看对话中的 Skill 调用或 `~/.coding-discipline/usage.jsonl`，记录实际被正式触发的 skill 集合；只把 SKILL.md 当文件读过不算触发。
   - **Codex**：当前没有可挂钩的按-skill 事件，不能假装存在「触发日志」。按场景中写明的关键行为人工验收（是否先澄清、先定位根因、先验红、先验证再声明等），结果记为行为通过 / 失败；不要把模型事后自报当成正式调用证据。
4. Claude Code 对照期望集记录误触发 / 漏触发；Codex 对照同一组条件记录行为偏差，并单独标注平台，二者数据不混算。

## 验收标准（不对称，两类错误代价不同）

- **底线 skill 漏触发零容忍**：`verify-before-done`、`systematic-debugging`（根因不明时）、`context-hygiene`（文档冲突时）——任何一个场景漏了即不通过。
- **重流程 skill 优先压误触发**：`brainstorming`、`tdd` 在明确小改 / 无可测行为场景上触发了，即不通过；漏触发按场景标注的严重度个案判。
- 每个场景表格里标了自己的判级，以表格为准。
- Codex 的「零容忍」按对应关键行为是否出现判定，不要求当前不可观测的内部 skill 名称。

## 固定开销预算

除场景外，v0.6.0 还要满足：**固定注入开销（`hooks/skill-discipline.md` + 全部 SKILL.md description 之和）不高于 v0.5.0**。
对比方式（在仓库根跑，git-bash）：

```bash
for ref in v0.5.0 HEAD; do
  total=0
  for f in $(git ls-tree -r --name-only "$ref" | grep -E 'skills/.*/SKILL\.md$'); do
    desc=$(git show "$ref:$f" | sed -n 's/^description: //p')
    total=$((total + $(printf '%s' "$desc" | wc -m)))
  done
  primer=$(git show "$ref:plugins/coding-discipline/hooks/skill-discipline.md" | wc -m)
  echo "$ref: descriptions=$total chars, primer=$primer chars, total=$((total + primer)) chars"
done
```

按字符数对比（同为中文文本，字符数与 token 数近似同比例）；HEAD 的 total 不得高于 v0.5.0。

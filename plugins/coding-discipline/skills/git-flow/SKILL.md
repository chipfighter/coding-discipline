---
name: git-flow
description: 开新分支、用 worktree 并行、提交、或干完收尾时用。讲分支命名、约定式提交、短命分支、worktree 隔离、收尾合并/清理——具体保护分支/CI/合并方式以项目 CLAUDE.md 为准。
---

> 分支命名规则、哪条分支受保护、合并走直接 merge / PR / MR、合并触不触发 CI、**版本号怎么定 / 谁打 tag**——这些项目专属规则以本仓库 CLAUDE.md 为准，本 skill 只给通用纪律。

## 版本 / tag 收敛（仅当项目用 tag + CHANGELOG 管版本才适用；**tag = 版本书签，是否等于发布/部署以项目 CLAUDE.md 为准、别默认 tag=发布**）
- **开分支前先定版本**：先和负责人收敛「这次收敛到哪个 tag」——报「上一个 tag + backlog 现挂什么 + 这次像新能力还是修复 → 建议号」，**等负责人定调再开分支**。别埋头开干、做完才发现没处收口。
- **号码守 SemVer**：major=破坏性、minor=向后兼容加功能、patch=向后兼容修复；0.x 更宽松（minor=能力、patch=修复），拿不准往大 bump。「什么算 minor」以项目 CLAUDE.md 为准。
- **定了就冻结**：目标版本一经定调即冻结范围。中途新需求**默认进 backlog / 下一版**，不往在飞的版本塞；要加进当前版须显式拍板、并明说「挤掉 / 顺延什么」——绝不闷头追加（一个 tag 越堆越大、收不了口就是这么来的）。
- **commit scope 用组件名、不用版本号**（`feat(auth):` 不是 `feat(v1.2):`）：分支会删、commit 历史不会；版本改名 / 重收敛时组件域历史不会被标错。
- **收敛 = 关版本**：范围做完 → 分支合基线、CI 绿 → CHANGELOG 条目从 backlog 挪进新版本段 → 打 tag（谁打 / 怎么打以项目为准）→ backlog 只剩顺延项。

## 分支与提交
- 每次开发新开分支，**绝不**在主分支或别人分支上直接改。分支短命：尽快整合，别让它漂太久。
- 分支名带类型 + 简述（如 `feat/搜索分页`、`fix/登录超时`）；项目有命名规范就照项目的。
- 约定式提交：`type(scope): 说明`（feat/fix/refactor/docs/chore…）。小步提交，每个 commit 可独立回退。

## worktree 并行（要同时开几条线、或要和当前工作区隔离时）
- 先查**是不是已经在隔离工作区**了，是就别再套一层。
- 有原生 worktree 工具（如 EnterWorktree）就用原生，别手敲 `git worktree add` 制造 harness 看不见的幽灵状态；没原生工具才用 git 兜底。
- 自己建项目本地 worktree（`.worktrees/`）前，先确认它被 gitignore，否则会把 worktree 内容误提交。
- 建好先装依赖 + 跑一遍基线测试，红的先报出来再干活。

## 收尾
- 收尾**前先验证测试全过**（见 verify-before-done），红的不许进入合并/PR。
- 给**明确选项**让人选，别问开放式"接下来干啥"：① 合并回基线分支 ② 推送开 PR/MR ③ 原样保留 ④ 丢弃。
- 顺序铁律：**先合并并验证成功 → 再移除 worktree → 再删分支**（分支还被 worktree 引用时删不掉；`git worktree remove` 要先 cd 回主仓再跑）。
- 只清理**自己建**的 worktree，harness 建的别碰。丢弃要打字确认。不 force-push，除非明确要求。

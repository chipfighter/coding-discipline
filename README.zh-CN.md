# coding-discipline

**English** → [README.md](README.md)

**只加护栏，不接管工作流。** 日常改动零打扰；具名失败模式临近才介入，
介入就不松。

AI 编程助手经常以两种代价很高的方式失败：

1. **目标漂移。** 对话里已经拍板，但下一轮 session 读到过期 spec，
   继续实现旧目标。
2. **跳过步骤。** 需求还没对齐就写代码、根因没找到就修症状，或者没有
   最新证据就宣称完成。

`coding-discipline` 是一个轻量、与工作流无关的插件，同时处理这两类问题：

- **Spec 同步**：当后续 session 可能按过期意图继续工作时，把已经确认的
  目标、非目标、约束和验收标准写回当前真源。
- **风险触发纪律**：只有条件命中时才启用硬护栏，包括设计对齐、TDD、
  系统化调试、优先级评审、证据式验收、规范的 Git 流程和上下文卫生。

它**不会**替代 Plan 模式、启动子 agent、编排 worktree、选择模型，也不会
强迫每个任务都走 spec 流程。小改动保持轻量；风险条件一旦命中，对应
skill 就保持严格。

8 个 skill + 2 个 hook，安装一次，全局生效。支持 Claude Code 和 Codex。

<!-- TODO(demo)：录两段约 30 秒的视频后，在 github.com 编辑器里把本注释块
替换掉（直接把 .mp4 拖进去，GitHub 会托管）。

## 平时安静，关键时刻不松手

第一幕——日常小改动：没有任何 skill 触发，改完就结束。
第二幕——没有证据就宣称"完成"：verify-before-done 拦下，直到测试真正跑过。
-->

## 为什么做这个项目

周边工具解决的是不同层次的问题：

| 项目 | 主要职责 |
|---|---|
| [Superpowers](https://github.com/obra/superpowers) | 完整的软件开发方法论和 agent 工作流 |
| [Spec Kit](https://github.com/github/spec-kit) / [OpenSpec](https://github.com/Fission-AI/OpenSpec) | 显式的 spec-driven 工作流和制品生命周期 |
| **coding-discipline** | 不接管工作流，只负责保存意图并阻止高风险捷径的小型护栏层 |

如果你觉得裸用 coding agent 不够稳，但又不想再加一层编排系统，这个项目
就是为这种需求设计的。

### 实测固定开销

这一层每个 session 的固定上下文开销，和完整工作流框架其实差不多——我们
把两边都测了，脚本公开：

| 每 session 固定注入（2026-07-17 实测） | coding-discipline (main) | superpowers v6.1.1 |
|---|---|---|
| SessionStart hook 注入文本 | 1,474 字符 | 3,277 字符 |
| skill 元数据（name + description） | 3,392 字符（8 个 skill） | 2,279 字符（14 个 skill） |
| **合计** | **4,866 字符（约 1.2k tokens）** | **5,556 字符（约 1.4k tokens）** |

两边用同一套规则测量：SessionStart hook 注入的全部文本，加上宿主为路由
加载的 skill 元数据；skill 正文两边都不计入——它们只在触发时加载。复现
脚本见
[experiments/context-measure/measure_fixed_context.py](experiments/context-measure/measure_fixed_context.py)。

所以差别不在启动 tokens，而在介入频率。工作流框架把每一次对话都带进自己
的流程——brainstorm、plan 文档、子 agent 派发、评审循环；coding-discipline
在具名失败模式临近之前不出现，出现时也不新增子 agent、plan 文件或任何
制品。

## 安装

### Codex

```bash
codex plugin marketplace add chipfighter/coding-discipline
codex plugin add coding-discipline@coding-discipline
```

安装后新开一个 task。首次启用 hook 或 hook 内容变化时，Codex 会要求审核；
用 `/hooks` 查看并信任。

测试本地 checkout 时，把第一条命令换成：

```bash
codex plugin marketplace add .
```

### Claude Code

```text
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

第一条命令把本仓库添加为自托管插件源，第二条安装插件。安装后新开一个
session。本地测试时，把第一条中的仓库名换成本地路径。

### 只安装 skills，不安装 hooks（Codex）

Codex 原生支持 `SKILL.md`：

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/
```

Windows PowerShell：

```powershell
Copy-Item -Recurse "plugins\coding-discipline\skills\*" "$HOME\.agents\skills\"
```

这种方式没有 SessionStart 注入、用量计数和项目引导文档骨架。如果需要
全局纪律总纲，请先审核
`plugins/coding-discipline/hooks/skill-discipline.md`，再把它合并到
`~/.codex/AGENTS.md`，不要重复追加。

## 8 个 skills

每个 skill 的 description 同时定义触发条件和排除条件。只有 skill 被选中
后才加载完整正文。

| skill | 什么时候触发 |
|---|---|
| `spec-sync` | 已确认的目标、非目标、约束或验收需要跨 session 保留，但当前真源过期或缺失 |
| `brainstorming` | 需求有多种合理理解、设计需要取舍，或改错代价高 |
| `tdd` | 新增或修改的行为可以用自动化回归测试验证 |
| `systematic-debugging` | bug、失败或非预期行为的根因尚未确定 |
| `code-review` | 改动影响多个模块的配合、跨越高风险边界，或用户明确要求评审 |
| `verify-before-done` | 宣称完成、修复、测试通过或可以交付之前 |
| `git-flow` | 分支、worktree、提交、tag 或分支收尾 |
| `context-hygiene` | 进入项目、读取项目历史或处理互相冲突的文档 |

这些 skill 故意保持很短，只保留模型经常跳过的硬判断规则；普通的规划和
执行仍由 harness 负责。

## 2 个 hooks

- **SessionStart 纪律总纲**：注入一段精简、平台中立的纪律，要求正式调用
  命中的 skill，维护指令优先级，并要求 agent 用用户的语言回答、用仓库
  已有语言编写文件和注释。
- **被动本地用量计数**：把 session 激活记录追加到
  `~/.coding-discipline/usage.jsonl`。Claude Code 还可以记录每个 skill
  的调用。数据不会上传。

查看本地汇总：

```bash
bash plugins/coding-discipline/hooks/skills-count.sh
```

关闭计数：

```bash
CD_USAGE_ENABLED=0
```

## 自动生成项目引导文档

第一次在 Git 仓库中开启 session 时，如果目标文件不存在，插件会创建一份
空骨架：

- Claude Code → `CLAUDE.md`
- Codex → `AGENTS.md`

即使从子目录或 worktree 启动，文件也只会生成在仓库根目录。已有文件永不
覆盖。设置 `CD_SEED_AGENT_DOC=0` 可以关闭。

英文骨架故意保持精简，只应记录已经确认、且无法从代码推断的项目事实。
Agent 仍然会用用户的语言回答。引导文档是共享的项目上下文，不是本机缓存：
团队和后续 session 需要的已确认规则通常应该提交到仓库，但绝不能在里面写
密钥、令牌或个人隐私。

## 能力边界

Skill 是提示词层面的纪律，不是确定性规则引擎。它能降低失败概率，但不能
保证路由和执行永远正确。

需要更强约束时：

- 不想让模型判断路由，就显式调用 skill；
- 把仓库专属硬规则写进该项目的 `CLAUDE.md` 或 `AGENTS.md`；
- 把机械性要求交给 CI、lint、测试、分支保护和 required review。

误触发和漏触发请通过仓库的 routing feedback issue 模板反馈。回归案例只
从真实失败中生长，不维护人工场景发版套件。

## 依赖

- **bash**：macOS 和 Linux 自带；Windows 安装
  [Git for Windows](https://git-scm.com/download/win)，`run-hook.cmd`
  会找到 Git Bash，并避免误用 WSL 的 `bash.exe`。
- 不需要 `jq`：JSON 转义和本地记录全部使用纯 bash。

## 开发与验证

```bash
python tests/test-plugin-metadata.py
bash tests/test-hooks.sh
```

Windows：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-windows-hook.ps1
```

元数据测试把英文固定上下文基线冻结为 4580 个字符（v0.8.0 时为 4944，
去重删减后重新冻结）：SessionStart 总纲与 8 条 skill description 的总长度
不能增长，除非从其他位置删掉等量内容。GitHub Actions 会在 Ubuntu 和 Windows 上执行相同验证。

## 致谢

纪律理念与跨平台 hook 基础——包括 polyglot `run-hook.cmd`、SessionStart
注入和纯 bash JSON 转义——来自 Jesse Vincent 的
[Superpowers](https://github.com/obra/superpowers)（MIT）。本项目把这套
基础收敛为不接管工作流的护栏层，并加入 spec 同步、风险触发路由和
Windows / Git-Bash 支持。

## License

MIT — 见 [LICENSE](LICENSE)。

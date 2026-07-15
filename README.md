# coding-discipline

**English** → [README_EN.md](README_EN.md)

给 AI 编程助手用的一套通用编程纪律插件：7 个 skill + 2 个 hook，装一次全局生效，Claude Code 和 Codex 都能用。

它管的事很简单：需求没对齐先对齐、可测的行为先写测试、修 bug 先找根因、说「做完了」之前先拿证据。每条 skill 只有 30 行左右，条件命中才触发——小改动不打扰，触发了就不讲价。

## 安装

### Codex

```bash
codex plugin marketplace add chipfighter/coding-discipline
codex plugin add coding-discipline@coding-discipline
```

装完新开一个 task 生效。第一次启用或 hook 变更后，Codex 会要求审核 hook，用 `/hooks` 查看并信任。想先本地试装，把第一行换成 `codex plugin marketplace add .`。

### Claude Code

```
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

第一行把本仓库添加为插件源（自托管分发，不走官方商店），第二行安装。装完新开一个 session 生效。想先本地试装，把第一行的仓库名换成本地路径。

### 只要 skills、不要 hook（Codex）

Codex 原生支持 `SKILL.md`，直接把 7 个 skill 拷进用户技能目录就能用：

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/
```

Windows PowerShell 用 `Copy-Item -Recurse "plugins\coding-discipline\skills\*" "$HOME\.agents\skills\"`。

这种装法没有 SessionStart 注入、计数和自动骨架。想要全局纪律，自行把 `hooks/skill-discipline.md` 的内容合并进 `~/.codex/AGENTS.md`（别重复追加）。

## 里面有什么

### 7 个 skill（条件命中才触发）

| skill | 什么时候触发 |
|---|---|
| `brainstorming` | 需求多解、方案要取舍、或改错代价高（权限 / 支付 / 迁移 / 对外接口）——先问清需求和设计、拿到批准再实现；明确的单点小改不触发 |
| `tdd` | 行为能用自动化测试验证——红 → 绿 → 重构，没有失败测试就不写实现；文档 / 配置类改动不触发 |
| `systematic-debugging` | 根因不明的 bug / 测试失败——先复现、反向追根因、根上修一处、补回归；报错直指原因的直接修 |
| `code-review` | 多个模块需要配合 / 高风险内容 / 用户要求——按「正确性 → 合需求 → 安全 → 简洁 → 风格」看；纯文档 / 配置值 / 机械改名不因进 PR 触发 |
| `verify-before-done` | 宣称"做好了"之前，任何任务不例外——只认最后一次相关改动后拿到、且刚好能证明结论的证据 |
| `git-flow` | 开分支 / worktree / 提交 / 收尾——只给通用纪律，项目专属规则以项目自己的 `AGENTS.md` / `CLAUDE.md` 为准 |
| `context-hygiene` | 读取项目文档 / 历史时——当前状态只看项目指定的最新文档，不主动读归档，也不另抄一套 spec |

### 2 个 hook（启用即生效，不用手改 settings）

- **SessionStart 注入**：每个 session 开场注入一段很短的「技能纪律」总纲——触发条件写在各 skill 的 description 里，命中必须调、未命中不硬调；优先级：用户最新指令 > 当前项目引导文档 > 本纪律。正文在 `hooks/skill-discipline.md`，想改口味直接改它。
- **用量计数**：纯本地、不联网，记到 `~/.coding-discipline/usage.jsonl`——每开一个 session 记一次激活；Claude Code 上还能记到每次 skill 触发。看汇总跑 `bash hooks/skills-count.sh`，不想记就在启动前设 `CD_USAGE_ENABLED=0`。

## 能力边界（诚实声明）

skill 是提示词纪律，不是能保证每次执行的规则引擎——它降低失败概率，不提供 100% 保证。模型读不懂 description、判断不准该用哪个 skill 时，用三种更可靠的办法兜底：

- 显式调用某个 skill（绕过自动路由）；
- 在项目自己的 `CLAUDE.md` / `AGENTS.md` 里给关键目录 / 行为写硬规则——比如想要「本仓库所有 PR 都过 code-review」，写一行就行；
- 真正要求每次都执行的事，交给 CI、lint、测试、required review 等硬性设施。

路由出错（不该触发的触发了 / 该触发的没触发）请用仓库的「路由反馈」issue 模板报告——回归案例只从真实失败里长出来。

## 项目引导文档：自动落一份空骨架

第一次在某个 git 仓库开 session，插件会在仓库根放一份空的引导文档骨架——Claude Code 落 `CLAUDE.md`，Codex 落 `AGENTS.md`：

- 只在文件不存在时创建、绝不覆盖已有的；从子目录或 worktree 启动也能找对仓库根。不想要就在启动前设 `CD_SEED_AGENT_DOC=0`。
- 骨架故意是空的：每和用户拍板一件「光看代码看不出来」的事就补一行，随项目长大（规矩见 `context-hygiene`）。填满的参考样例见 [templates/CLAUDE.md](templates/CLAUDE.md)，不必照拷。

## 依赖

- **bash** —— macOS / Linux 自带；Windows 装 [Git for Windows](https://git-scm.com/download/win)，hook 通过 `hooks/run-hook.cmd` 自动找到 git-bash（故意不用 WSL 的 bash）。
- 不需要 jq —— JSON 转义全用纯 bash，三平台行为一致。

## 开发与验证

```bash
python tests/test-plugin-metadata.py   # manifest / hooks / skills 元数据
bash tests/test-hooks.sh               # hook 行为（Linux / Git Bash）
```

元数据测试同时约束每个 session 的固定注入开销（SessionStart 总纲 + 全部 skill description）不超过 v0.5.0 基线。触发效果以真实使用反馈持续校准，不设人工场景发版门槛。

Windows 上再跑一遍真实的 Windows 入口：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-windows-hook.ps1
```

GitHub Actions 在 Ubuntu 和 Windows 上跑同样的验证。

## 致谢

纪律理念与跨平台 hook 机制（polyglot `run-hook.cmd`、SessionStart 注入、无 jq 的纯 bash JSON 转义）来自 [superpowers](https://github.com/obra/superpowers)（Jesse Vincent，MIT）。本项目把这套思路收敛成一组精简的中文纪律 skill，并补齐了 Windows / git-bash 适配。

## License

MIT — 见 [LICENSE](LICENSE)。

# coding-discipline

**English** → [README_EN.md](README_EN.md)

给 AI 编程助手用的一套通用编程纪律插件：8 个 skill + 2 个 hook，装一次全局生效，Claude Code 和 Codex 都能用。

它管的事很简单：动手前先对齐方案、先写测试再写实现、修 bug 先找根因、说「做完了」之前先拿运行证据。每条 skill 只有 30 行左右，只写模型自己想不到的硬规矩。

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

Codex 原生支持 `SKILL.md`，直接把 8 个 skill 拷进用户技能目录就能用：

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/
```

Windows PowerShell 用 `Copy-Item -Recurse "plugins\coding-discipline\skills\*" "$HOME\.agents\skills\"`。

这种装法没有 SessionStart 注入、计数和自动骨架。想要全局纪律，自行把 `hooks/skill-discipline.md` 的内容合并进 `~/.codex/AGENTS.md`（别重复追加）。

## 里面有什么

### 8 个 skill（按需自动触发）

| skill | 什么时候用 |
|---|---|
| `brainstorming` | 做任何创造性的活、动手写代码之前——先问清需求和设计、拿到批准再实现 |
| `tdd` | 实现功能 / 修 bug 之前——红 → 绿 → 重构，没有失败测试就不写实现 |
| `development` | 照已定方案实现——拆小块、每块 TDD、省上下文、整合后验证 |
| `systematic-debugging` | 碰到 bug / 测试失败——先复现、反向追根因、根上修一处、补回归 |
| `code-review` | 完成一块 / 合并前——按「正确性 → 合需求 → 安全 → 简洁 → 风格」看 |
| `verify-before-done` | 宣称"做好了"之前——先真跑验证命令、看到输出再下结论 |
| `git-flow` | 开分支 / worktree / 提交 / 收尾——只给通用纪律，项目专属规则以项目自己的 `AGENTS.md` / `CLAUDE.md` 为准 |
| `context-hygiene` | 载入项目文档 / 上下文时——现状只认当下真源、绝不主动读归档、别养平行 spec 库 |

### 2 个 hook（启用即生效，不用手改 settings）

- **SessionStart 注入**：每个 session 开场注入一段很短的「技能纪律」总纲——哪怕 1% 可能相关也先调对应 skill、先流程后实现、用户指令和项目引导文档永远压过本纪律。正文在 `hooks/skill-discipline.md`，想改口味直接改它。
- **用量计数**：纯本地、不联网，记到 `~/.coding-discipline/usage.jsonl`——每开一个 session 记一次激活；Claude Code 上还能记到每次 skill 触发。看汇总跑 `bash hooks/skills-count.sh`，不想记就在启动前设 `CD_USAGE_ENABLED=0`。

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

Windows 上再跑一遍真实的 Windows 入口：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-windows-hook.ps1
```

GitHub Actions 在 Ubuntu 和 Windows 上跑同样的验证。

## 致谢

纪律理念与跨平台 hook 机制（polyglot `run-hook.cmd`、SessionStart 注入、无 jq 的纯 bash JSON 转义）来自 [superpowers](https://github.com/obra/superpowers)（Jesse Vincent，MIT）。本项目把这套思路收敛成一组精简的中文纪律 skill，并补齐了 Windows / git-bash 适配。

## License

MIT — 见 [LICENSE](LICENSE)。

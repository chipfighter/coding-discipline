# coding-discipline

**English** → [README_EN.md](README_EN.md)

> Lean-but-sharp coding-discipline skills for AI coding agents —— 一套「瘦但有牙」的通用编程纪律 skill + hooks,装一次、全局生效、跨项目、跨 AI 编程助手(Claude Code · Codex)通用。

管的是「**怎么把活干好**」:设计先行、先写测试、先找根因、按优先级评审、拿证据再说完成、规矩地走 git 流程。每条 skill 只留**模型不知道的硬纪律**(~30 行),删掉解释和废话——所以叫「瘦但有牙」。

## 安装(作为 Claude Code plugin)

> ⚠️ coding-discipline 走**自托管分发**——不在官方插件商店里,而是把**本仓库当作你的插件源**。下面第一行就是「添加这个源」,第二行才是「安装」。这是完全正常、能用的第三方安装方式。

```
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

装完**新开一个 session** 才生效(见下面「自动注入」)。想本地先试,把上面第一行换成本地路径:

```
/plugin marketplace add ~/Desktop/coding-discipline
/plugin install coding-discipline@coding-discipline
```

## 里面有什么

### 8 个纪律 skill(按需自动触发)

| skill | 什么时候用 |
|---|---|
| `brainstorming` | 做任何创造性的活、动手写代码之前——先问清需求和设计、拿到批准再实现 |
| `tdd` | 实现功能 / 修 bug 之前——红 → 绿 → 重构,没有失败测试就不写实现 |
| `development` | 照已定方案实现——拆小块、每块 TDD、省上下文、整合后验证 |
| `systematic-debugging` | 碰到 bug / 测试失败——先复现、反向追根因、根上修一处、补回归 |
| `code-review` | 完成一块 / 合并前——按「正确性 → 合需求 → 安全 → 简洁 → 风格」看 |
| `verify-before-done` | 宣称"做好了"之前——先真跑验证命令、看到输出再下结论 |
| `git-flow` | 开分支 / worktree / 提交 / 收尾——只给通用纪律,项目专属规则让位给项目自己的 `CLAUDE.md` |
| `context-hygiene` | 载入项目文档 / 上下文时——现状只认当下真源、绝不主动读归档、别养平行 spec 库,防过期文档带偏方向 |

### 2 个 hook(启用 plugin 即生效,无需手改 settings)

- **SessionStart 注入**:每个 session 开场,把一段极短的「技能纪律」总纲注入进来——「哪怕 1% 相关也先调对应 skill」「先流程后实现」「用户指令 / 项目 `CLAUDE.md` 永远压过本纪律」。这是让 skill 被**勤触发**的关键(不靠描述碰运气)。总纲正文在 `hooks/skill-discipline.md`,想改口味直接改它。
- **用量计数(跨平台,纯本地、不联网)**:被动记录你用了多少,存到 `~/.coding-discipline/usage.jsonl`。
  - 记两档:**会话激活**——每开一个 session 记一次(Codex / Cursor / Claude Code 通用,靠 SessionStart);**按 skill 明细**——每次真正触发某个 skill 记一次(目前只有 Claude Code 能精确记,靠 PostToolUse 钩 `Skill` 调用)。
  - **怎么看:** 跑 `bash hooks/skills-count.sh`,打印各档次数汇总。

## 项目引导文档:自动生成、随项目长大

装了插件后,你**第一次**在某个项目(git 仓库根)里开 session,插件会**自动放一份空骨架**引导文档,不用再手动拷:

- **Claude Code** 落 `CLAUDE.md`、**Codex** 落 `AGENTS.md`——各读各的那个文件,自动认平台。
- **只在没有**引导文档时建、**绝不覆盖**你已有的;只在 git 仓库根动手。这份文件本身就是「已建」的记号——下个 session 零打扰、零上下文开销。
- 骨架**故意几乎是空的**。它不是开工前写死的说明书,而是随项目往前走、**每拍板一件事就补一行**、慢慢长出来的:只记「已确认、且光看代码看不出来」的事(技术选型 / 硬边界 / 完成标准),变了改原行、不追加(这套规矩由 `context-hygiene` 管)。

> 想看一份「填满了大概长啥样」的参考,见 [templates/CLAUDE.md](templates/CLAUDE.md)(带 ★ 的完整版,给你手动参考,**不必照拷**)。
> 通用编程纪律(先对齐 / TDD / 评审 / git 流程 / 上下文防毒)由插件全局提供,骨架和模板里都**不重复**。

## 在 Codex 上用(给用 Codex 的朋友)

同一套 skill 直接能用——Codex 原生支持 `SKILL.md`(`name` / `description` frontmatter),格式和这里一模一样。

**最简(试用):** 把 skills 放进 Codex 技能目录,纪律总纲写进全局 `AGENTS.md`:

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/            # 1. 装 8 条 skill
cat plugins/coding-discipline/hooks/skill-discipline.md >> ~/.codex/AGENTS.md   # 2. 注入纪律总纲
```

之后 Codex 会按描述自动加载对应 skill,或在提示里用 `$skill-name` 显式触发。

**作为 Codex plugin(完整形态):** 仓库已带 `.codex-plugin/plugin.json` + `hooks/hooks-codex.json`(SessionStart 注入,机制同 superpowers);以正式 plugin 装上时,会话激活计数、以及**首次进项目自动生成 `AGENTS.md` 空骨架**(同上文,文件名按 Codex 来)都随之生效。上面「最简试用」那种只拷 skill、不装 hook 的方式**不会**自动生成,需要你手动建 `AGENTS.md`。

> **计数说明:** Codex 上只有**会话激活**能统计(且需以 plugin 形态装、让 `hooks-codex.json` 的 SessionStart 跑起来);**按 skill** 精确计数是 Claude Code 专属——Codex 的 skill 是渐进式内部加载、非工具调用,没有可挂钩的按-skill 事件。

## 依赖

- **`bash`** —— macOS / Linux 自带;Windows 用 [Git for Windows](https://git-scm.com/download/win) 的 git-bash(Claude Code on Windows 本就依赖它)。hook 通过 polyglot 包装器 `hooks/run-hook.cmd` 自动找到正确的 bash,在 Windows 上**故意绕开 WSL 的 `system32\bash.exe`**。
- **不需要 jq** —— 所有 JSON 转义 / 解析都用纯 bash 完成,零外部依赖,Windows / macOS / Linux 全平台一致。

> 跨平台原理:hook 脚本用**无扩展名**文件名(避开 Claude Code 在 Windows 上对含 `.sh` 命令自动加 `bash` 前缀);由 `run-hook.cmd`(既是合法 batch 又是合法 bash 的 polyglot)分发——cmd.exe 走批处理段找 git-bash,Unix shell 走末尾的 bash 段。此机制照搬官方 superpowers 的经过验证的做法。

## 致谢

本项目的**纪律理念**与**跨平台 hook 机制**(polyglot `run-hook.cmd`、SessionStart 注入、纯 bash 无 jq 的转义做法)借鉴自 [superpowers](https://github.com/obra/superpowers)(by Jesse Vincent,MIT)。coding-discipline 把那套思路收敛成一组「瘦但有牙」的中文纪律 skill——每条只留模型不知道的硬规矩,并补齐了 Windows / git-bash 适配。感谢 superpowers 趟平了路。

## License

MIT — 见 [LICENSE](LICENSE)。

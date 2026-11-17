# coding-discipline

**English** · [README.md](README.md)

一个适用于 Claude Code 和 Codex 的轻量插件。它帮助你查清复杂故障的根因，并把已经确认、后续会话还要用的项目决定写回现行规格。方案讨论和测试驱动开发可以按需调用。

## 安装

### Codex

```text
codex plugin marketplace add chipfighter/coding-discipline
codex plugin add coding-discipline@coding-discipline
```

安装后新开一个对话。测试本地副本时，在仓库根目录执行以下命令，替换第一条命令。

```text
codex plugin marketplace add .
```

### Claude Code

```text
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

安装后新开一个会话。测试本地副本时，把第一条命令中的 `chipfighter/coding-discipline` 换成本地路径。

### 单独安装 Codex 技能

在仓库根目录把需要的技能目录复制到 `~/.agents/skills/`。保留完整目录，Codex 才能读取其中的调用设置。

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/
```

Windows PowerShell

```powershell
$skillDirectory = Join-Path $HOME ".agents/skills"
New-Item -ItemType Directory -Force -Path $skillDirectory | Out-Null
Copy-Item -Recurse "plugins/coding-discipline/skills/*" $skillDirectory
```

插件无需安装 Bash，也没有启动钩子和用量记录。

## 技能

| 技能 | 调用方式 | 适用场景 |
|---|---|---|
| `systematic-debugging` | 自动或手动 | 根因不明、故障跨组件，或上次修复没奏效。先收集证据、追查根因，再验证修复。 |
| `spec-sync` | 自动或手动 | 已确认的目标、非目标、约束或验收标准会改变后续会话的工作。找到现行规格，只更新相关原文。 |
| `brainstorming` | 手动 | 一个设计决策会实质影响结果，或选错代价很高，需要先讨论取舍。 |
| `tdd` | 手动 | 某个行为值得用针对性的自动化测试覆盖时，采用先写失败测试、再实现、最后重构的流程。 |

在 Codex 中输入 `$` 并选中对应技能。在 Claude Code 中使用插件命令，例如 `/coding-discipline:brainstorming` 或 `/coding-discipline:tdd`。

日常审查和 worktree 管理由宿主提供。项目专用的审查要求、Git 约定和验收命令写在仓库指令里。最后一次相关修改后，执行足以支撑结论的检查，说明实测结果和未验证项。合并前必须通过的检查交给 CI 和分支保护。

## 项目指令

保留已有的 `AGENTS.md` 和 `CLAUDE.md`。插件已取消启动时自动创建这两个文件的行为。项目确实需要指令时，用对应工具的 `/init` 初始化。适合写进去的是现行规格的入口、测试命令，以及仅凭代码难以推断的约定。

Codex 和新版 Claude Code 可以共用 `AGENTS.md`。如果仓库需要独立的 `CLAUDE.md`，在里面用 `@AGENTS.md` 引入共享规则，再补充 Claude 专用指令。 [Claude Code 项目指令](https://code.claude.com/docs/en/memory#share-one-file-with-other-coding-tools)

## 反馈与安全

自动调用可能误触发或漏触发。遇到这两种情况，或者手动调用失败，可以使用[路由反馈模板](.github/ISSUE_TEMPLATE/routing-feedback.md)。

`tests/test-skill-safety.py` 扫描插件分发的文件，检查凭据路径、网络外传、进入 shell 的管道、解码执行和隐藏或双向 Unicode 字符等已知模式。每条规则都用一个应命中的样本验证。

## 开发与验证

```text
python tests/test-plugin-metadata.py
python tests/test-skill-safety.py
```

GitHub Actions 会在 Ubuntu 和 Windows 上执行这两项检查。安装了 Claude Code 的话，还可以使用它的校验命令检查插件源、插件和技能。

```text
claude plugin validate --strict .
claude plugin validate --strict plugins/coding-discipline
claude plugin validate --strict plugins/coding-discipline/skills
```

## 致谢

本项目早期的工程纪律和跨平台钩子设计受到 Jesse Vincent 的 [Superpowers](https://github.com/obra/superpowers)（MIT）启发。

## 许可证

MIT · [LICENSE](LICENSE)

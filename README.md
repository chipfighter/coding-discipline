# coding-discipline

**Chinese** · [README.zh-CN.md](README.zh-CN.md)

A small plugin for Claude Code and Codex. It helps trace bugs with an unclear
cause and keeps confirmed project decisions available across sessions.
Brainstorming and test-driven development are available when you ask for them.

## Install

### Codex

```text
codex plugin marketplace add chipfighter/coding-discipline
codex plugin add coding-discipline@coding-discipline
```

Open a new chat after installation. To test a local checkout, run the following
from the repository root in place of the first command.

```text
codex plugin marketplace add .
```

### Claude Code

```text
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

Open a new session after installation. To test a local checkout, replace
`chipfighter/coding-discipline` in the first command with the local path.

### Copy individual Codex skills

From the repository root, copy the directories for the skills you want to
`~/.agents/skills/`. Keep each directory intact so that Codex can read its
invocation settings.

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

The plugin has no hooks, usage logging, or shell dependencies.

## Skills

| Skill | Invocation | When to use it |
|---|---|---|
| `systematic-debugging` | Automatic or explicit | The cause is unclear, the failure crosses component boundaries, or a previous fix failed. Gather evidence, trace the cause, and verify the fix. |
| `spec-sync` | Automatic or explicit | A confirmed outcome, non-goal, constraint, or acceptance criterion changes what future sessions should do. Find the current source of truth and update the affected text. |
| `brainstorming` | Explicit | Discuss a decision whose tradeoffs affect the result or could cause significant rework. |
| `tdd` | Explicit | Use red, green, and refactor for behavior that benefits from a focused automated test. |

In Codex, type `$` and select the skill. In Claude Code, use the plugin
command, for example `/coding-discipline:brainstorming` or
`/coding-discipline:tdd`.

Use the host's review and worktree features for routine operations. Put
project-specific review criteria, Git conventions, and acceptance commands in
the repository's own instructions. After the last relevant edit, run the
checks that support your completion claim and report any gaps. Use CI and
branch protection for checks that must pass before merge.

## Project instructions

Keep existing `AGENTS.md` and `CLAUDE.md` files. The plugin no longer creates
them at startup. Use the host's `/init` command when a project needs a guide.
Good entries include the current spec, the test command, and conventions the
agent cannot reliably infer from the code.

Codex and current Claude Code can share `AGENTS.md`. When a repository
needs a separate `CLAUDE.md`, add `@AGENTS.md` to it and put any Claude-specific
instructions below the import. [Claude Code project instructions](https://code.claude.com/docs/en/memory#share-one-file-with-other-coding-tools)

## Feedback and security

Skills guide the model, and automatic invocation can miss or overmatch. Use the
[routing feedback template](.github/ISSUE_TEMPLATE/routing-feedback.md) to
report a misfire or an explicit invocation that failed.

`tests/test-skill-safety.py` scans the shipped files for known attack patterns,
including references to credentials, network exfiltration, shell pipelines,
decoded execution, and hidden or bidirectional Unicode. A known-bad sample
checks that each rule still matches.

## Development and verification

```text
python tests/test-plugin-metadata.py
python tests/test-skill-safety.py
```

GitHub Actions runs both checks on Ubuntu and Windows. If Claude Code is
installed, its validator can also check the marketplace, plugin, and skills.

```text
claude plugin validate --strict .
claude plugin validate --strict plugins/coding-discipline
claude plugin validate --strict plugins/coding-discipline/skills
```

## Credits

The original engineering discipline and cross-platform hook patterns were
inspired by Jesse Vincent's [Superpowers](https://github.com/obra/superpowers)
(MIT).

## License

MIT · [LICENSE](LICENSE)

# coding-discipline

**中文** → [README.md](README.md)

> Lean-but-sharp coding-discipline skills for AI coding agents — a set of universal engineering-discipline skills + hooks. Install once, applies globally, across projects and across agents (Claude Code · Codex).

It governs **how the work gets done well**: design first, test first, root-cause first, priority-ordered review, evidence before "done", disciplined git flow. Each skill keeps only the **hard rules the model doesn't already know** (~30 lines), stripping the explanations and filler — that's why it's "lean but sharp".

## Install

### Codex plugin (recommended)

This repository includes a current Codex marketplace file (`.agents/plugins/marketplace.json`), plugin manifest, skills, and a SessionStart hook. Add the repository and install it with the Codex CLI:

```bash
codex plugin marketplace add chipfighter/coding-discipline
codex plugin add coding-discipline@coding-discipline
```

Start a new task after installation. The first time the hook is enabled, and whenever its definition changes, Codex asks you to review it; use `/hooks` to inspect and trust it.

To install from a local checkout:

```bash
codex plugin marketplace add .
codex plugin add coding-discipline@coding-discipline
```

### Claude Code plugin

> ⚠️ coding-discipline is **self-hosted** — it is not in any official plugin store. Instead you add **this repository as your plugin source**. The first line below adds the source; the second installs. This is a normal, fully-working third-party install.

```
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

Start a **new session** for it to take effect (see "auto-injection" below). To try it from a local checkout, swap the first line for a local path:

```
/plugin marketplace add ~/Desktop/coding-discipline
/plugin install coding-discipline@coding-discipline
```

## What's inside

### 8 discipline skills (auto-triggered on demand)

| skill | when it fires |
|---|---|
| `brainstorming` | before any creative work / writing code — pin down requirements & design, get sign-off first |
| `tdd` | before implementing a feature / fixing a bug — red → green → refactor; no implementation without a failing test |
| `development` | implementing an agreed plan — split into small pieces, TDD each, save context, verify after integration |
| `systematic-debugging` | on a bug / test failure — reproduce, trace back to root cause, fix once at the root, add a regression test |
| `code-review` | finishing a piece / before merge — review by "correctness → meets-requirements → security → simplicity → style" |
| `verify-before-done` | before claiming "it works" — actually run the verification command and read the output first |
| `git-flow` | branching / worktrees / commits / wrap-up — general discipline only; project-specific rules defer to `AGENTS.md` / `CLAUDE.md` |
| `context-hygiene` | loading project docs / context — trust the current source of truth, don't read archives by default, don't grow a parallel spec library |

### 2 hooks (active as soon as the plugin is enabled — no manual settings edits)

- **SessionStart injection**: at the start of every session, inject a short discipline primer — invoke a skill when its workflow clearly matches, put process before implementation, and always defer to user instructions and the active project guide. The primer body lives in `hooks/skill-discipline.md` — edit it to taste.
- **Usage counting (cross-platform)**: unified log at `~/.coding-discipline/usage.jsonl` (local only, no network). Two tiers of granularity — **session activation** is counted per platform (works on Codex / Cursor / Claude Code via SessionStart), while **per-skill** detail is only precisely recordable on Claude Code. View stats: `bash hooks/skills-count.sh`.
  - Set `CD_USAGE_ENABLED=0` before starting Codex or Claude Code to disable logging completely.

## Project guide doc: auto-generated, grows with the project

Once the plugin is installed, the **first** time you open a session anywhere in a Git project, the plugin **drops an empty skeleton** guide doc at the repository root:

- **Claude Code** gets `CLAUDE.md`, **Codex** gets `AGENTS.md` — each platform reads its own file; detection is automatic.
- Repository discovery uses `git rev-parse`, so nested start directories, Git worktrees, and `.git` pointer files are supported.
- It creates only the current platform's missing guide and **never overwrites** an existing file. A `CLAUDE.md` does not block Codex from creating `AGENTS.md`, or vice versa.
- A guide created by SessionStart is picked up from the next task/session onward.
- Set `CD_SEED_AGENT_DOC=0` before starting the agent to disable automatic guide creation.
- The skeleton is **deliberately almost empty**. It is not an upfront spec written before the work starts, but a doc that **grows one line per decision** as the project moves forward: it records only what is "confirmed, and not derivable from reading the code" (tech choices / hard boundaries / definition of done). When something changes, edit the line in place instead of appending (this regime is governed by `context-hygiene`).

> For a reference of what a filled-in one looks like, see [templates/CLAUDE.md](templates/CLAUDE.md) (the ★ full version, for manual reference — **no need to copy it verbatim**).
> The universal discipline (align-first / TDD / review / git flow / context-poisoning defense) is provided globally by the plugin and is **not repeated** in the skeleton or the template.

## Install only the Codex skills (no hooks)

The same skills work directly — Codex natively supports `SKILL.md` (with `name` / `description` frontmatter), the exact format used here.

To try only the eight skills, copy them into the Codex user skill directory. You do not need to change the global `AGENTS.md`:

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/
```

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force "$HOME\.agents\skills" | Out-Null
Copy-Item -Recurse -Force "plugins\coding-discipline\skills\*" "$HOME\.agents\skills\"
```

Codex then auto-loads a matching skill from its description, or you can invoke one explicitly with `$skill-name`. Skills-only installation does not run SessionStart, count usage, or create `AGENTS.md`. If you deliberately want the discipline primer globally, review it and merge `hooks/skill-discipline.md` into `~/.codex/AGENTS.md`; do not append it repeatedly.

> **Counting note:** on Codex only **session activation** can be tracked (and only when installed as a plugin so `hooks-codex.json`'s SessionStart runs); **per-skill** counting is Claude-Code-only — Codex loads skill bodies via internal progressive disclosure, not a tool call, so there is no hookable per-skill event.

## Dependencies

- **`bash`** — built in on macOS / Linux; on Windows use [Git for Windows](https://git-scm.com/download/win) git-bash. Hooks find the right bash and restore Git Bash's POSIX tool paths through `hooks/run-hook.cmd`, which on Windows **deliberately avoids WSL's `system32\bash.exe`**.
- **No jq required** — all JSON escaping / parsing is done in pure bash, zero external dependencies, identical across Windows / macOS / Linux.

> Cross-platform mechanism: hook scripts use **extensionless** filenames (to dodge Claude Code's Windows auto-detection that prepends `bash` to any command containing `.sh`); `run-hook.cmd` (a polyglot that is both a valid batch file and a valid bash script) dispatches them — cmd.exe runs the batch branch and finds git-bash, Unix shells run the bash tail. This mechanism follows the proven approach from the official superpowers plugin.

## Development and verification

```bash
python tests/test-plugin-metadata.py
bash tests/test-hooks.sh
```

On Windows, also run the real `commandWindows` / Git Bash wrapper test:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-windows-hook.ps1
```

GitHub Actions runs these checks on both Ubuntu and Windows.

## Credits

This project's **discipline philosophy** and **cross-platform hook mechanism** (the polyglot `run-hook.cmd`, SessionStart injection, and the pure-bash / no-jq escaping) are adapted from [superpowers](https://github.com/obra/superpowers) (by Jesse Vincent, MIT). coding-discipline distills that approach into a set of "lean but sharp" Chinese-language discipline skills — each keeping only the hard rules the model doesn't already know — and adds Windows / git-bash support. Thanks to superpowers for paving the way.

## License

MIT — see [LICENSE](LICENSE).

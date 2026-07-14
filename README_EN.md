# coding-discipline

**中文** → [README.md](README.md)

> Lean-but-sharp coding-discipline skills for AI coding agents — a set of universal engineering-discipline skills + hooks. Install once, applies globally, across projects and across agents (Claude Code · Codex).

It governs **how the work gets done well**: design first, test first, root-cause first, priority-ordered review, evidence before "done", disciplined git flow. Each skill keeps only the **hard rules the model doesn't already know** (~30 lines), stripping the explanations and filler — that's why it's "lean but sharp".

## Install (as a Claude Code plugin)

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
| `git-flow` | branching / worktrees / commits / wrap-up — general discipline only; project-specific rules defer to the project's own `CLAUDE.md` |
| `context-hygiene` | loading project docs / context — trust only the current source of truth, never read archives, don't grow a parallel spec library |

### 2 hooks (active as soon as the plugin is enabled — no manual settings edits)

- **SessionStart injection**: at the start of every session, inject a very short "skill discipline" primer — "even 1% relevant → invoke the matching skill first", "process before implementation", "user instructions / project `CLAUDE.md` always override this primer". This is the key to skills firing **eagerly** (rather than relying on description luck). The primer body lives in `hooks/skill-discipline.md` — edit it to taste.
- **Usage counting (cross-platform)**: unified log at `~/.coding-discipline/usage.jsonl` (local only, no network). Two tiers of granularity — **session activation** is counted per platform (works on Codex / Cursor / Claude Code via SessionStart), while **per-skill** detail is only precisely recordable on Claude Code. View stats: `bash hooks/skills-count.sh`.

## Companion: a project `CLAUDE.md` template

Want this context discipline in your own project? **Install the plugin first (above), then** copy [templates/CLAUDE.md](templates/CLAUDE.md) into your project root and fill the two ★ sections:

- **"My doc structure"** — tells `context-hygiene` which file is the current source of truth and which are archives (so it knows what to read vs. never read).
- **"Project-specific"** — what this project is, its hard boundaries, how "done" is judged.

The universal discipline (align-first / TDD / review / git flow / context hygiene) is provided globally by the plugin and is **not repeated** in the template — that's why the template is thin. **Note: the template assumes the plugin is installed**; copying it without the plugin leaves those universal rules empty.

## Using it on Codex (for friends on Codex)

The same skills work directly — Codex natively supports `SKILL.md` (with `name` / `description` frontmatter), the exact format used here.

**Simplest (to try it):** drop the skills into Codex's skills directory and put the discipline primer into your global `AGENTS.md`:

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/            # 1. install the 8 skills
cat plugins/coding-discipline/hooks/skill-discipline.md >> ~/.codex/AGENTS.md   # 2. inject the discipline primer
```

Codex then auto-loads the matching skill by description, or you invoke one explicitly with `$skill-name` in the prompt.

**As a Codex plugin (full form):** the repo already ships `.codex-plugin/plugin.json` + `hooks/hooks-codex.json` (SessionStart injection, same mechanism as superpowers); installed as a proper plugin, session-activation counting comes along too.

> **Counting note:** on Codex only **session activation** can be tracked (and only when installed as a plugin so `hooks-codex.json`'s SessionStart runs); **per-skill** counting is Claude-Code-only — Codex loads skill bodies via internal progressive disclosure, not a tool call, so there is no hookable per-skill event.

## Dependencies

- **`bash`** — built in on macOS / Linux; on Windows use [Git for Windows](https://git-scm.com/download/win) git-bash (Claude Code on Windows relies on it anyway). Hooks find the right bash via the polyglot wrapper `hooks/run-hook.cmd`, which on Windows **deliberately avoids WSL's `system32\bash.exe`**.
- **No jq required** — all JSON escaping / parsing is done in pure bash, zero external dependencies, identical across Windows / macOS / Linux.

> Cross-platform mechanism: hook scripts use **extensionless** filenames (to dodge Claude Code's Windows auto-detection that prepends `bash` to any command containing `.sh`); `run-hook.cmd` (a polyglot that is both a valid batch file and a valid bash script) dispatches them — cmd.exe runs the batch branch and finds git-bash, Unix shells run the bash tail. This mechanism follows the proven approach from the official superpowers plugin.

## Credits

This project's **discipline philosophy** and **cross-platform hook mechanism** (the polyglot `run-hook.cmd`, SessionStart injection, and the pure-bash / no-jq escaping) are adapted from [superpowers](https://github.com/obra/superpowers) (by Jesse Vincent, MIT). coding-discipline distills that approach into a set of "lean but sharp" Chinese-language discipline skills — each keeping only the hard rules the model doesn't already know — and adds Windows / git-bash support. Thanks to superpowers for paving the way.

## License

MIT — see [LICENSE](LICENSE).

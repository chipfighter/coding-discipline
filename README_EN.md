# coding-discipline

**中文** → [README.md](README.md)

A coding-discipline plugin for AI coding agents: 7 skills + 2 hooks. Install once, applies globally, works with both Claude Code and Codex.

What it enforces is simple: align first when requirements are ambiguous, test-first for testable behavior, root-cause before fixing, and show run output before claiming "done". Each skill is ~30 lines and only fires when its trigger conditions match — small changes stay friction-free, but once triggered there is no bargaining.

## Install

### Codex

```bash
codex plugin marketplace add chipfighter/coding-discipline
codex plugin add coding-discipline@coding-discipline
```

Takes effect in a new task. The first time the hook is enabled (and whenever it changes), Codex asks you to review it — use `/hooks` to inspect and trust it. To try a local checkout, swap the first line for `codex plugin marketplace add .`.

### Claude Code

```
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

The first line adds this repository as a plugin source (self-hosted, not the official store); the second installs. Takes effect in a new session. To try a local checkout, swap the repo name in the first line for a local path.

### Skills only, no hooks (Codex)

Codex supports `SKILL.md` natively — just copy the 7 skills into your user skill directory:

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/
```

On Windows PowerShell: `Copy-Item -Recurse "plugins\coding-discipline\skills\*" "$HOME\.agents\skills\"`.

This route has no SessionStart injection, no usage counting, and no auto-seeded guide doc. If you want the discipline primer globally, review `hooks/skill-discipline.md` and merge it into `~/.codex/AGENTS.md` yourself (don't append it repeatedly).

## What's inside

### 7 skills (triggered only when conditions match)

| skill | when it fires |
|---|---|
| `brainstorming` | requirements have multiple readings, designs need a trade-off, or mistakes are costly (auth / payments / migrations / public APIs) — pin down requirements & design, get sign-off first; clear single-point changes don't trigger it |
| `tdd` | the behavior can be verified by automated tests — red → green → refactor; no implementation without a failing test; docs / config changes don't trigger it |
| `systematic-debugging` | a bug / test failure with an unclear root cause — reproduce, trace back to root cause, fix once at the root, add a regression test; errors that name their own cause get fixed directly |
| `code-review` | before merge / cross-module changes / high-risk surfaces / on request — review by "correctness → meets-requirements → security → simplicity → style" |
| `verify-before-done` | before claiming "it works", no task exempt — actually run the verification command and read the output first |
| `git-flow` | branching / worktrees / commits / wrap-up — general discipline only; project-specific rules defer to `AGENTS.md` / `CLAUDE.md` |
| `context-hygiene` | loading project docs / context — trust the current source of truth, never read archives proactively, don't grow a parallel spec library |

### 2 hooks (active as soon as the plugin is enabled)

- **SessionStart injection**: every session starts with a short discipline primer — trigger conditions live in each skill's own description; when they match you must invoke it, when they don't you don't invoke it for show, and user instructions / the project guide doc always override the primer. The body lives in `hooks/skill-discipline.md`; edit it to taste.
- **Usage counting**: local only, no network, appended to `~/.coding-discipline/usage.jsonl` — one record per session activation; on Claude Code also one per skill invocation. View stats with `bash hooks/skills-count.sh`; set `CD_USAGE_ENABLED=0` to disable.

## Project guide doc: an empty skeleton, seeded automatically

The first time you open a session in a Git repository, the plugin drops an empty guide-doc skeleton at the repo root — `CLAUDE.md` for Claude Code, `AGENTS.md` for Codex:

- Created only when missing, never overwrites an existing file; the repo root is found correctly from subdirectories and worktrees too. Set `CD_SEED_AGENT_DOC=0` to disable.
- The skeleton is deliberately empty: it grows one line per confirmed decision that can't be read from the code (governed by `context-hygiene`). For a filled-in reference see [templates/CLAUDE.md](templates/CLAUDE.md) — no need to copy it verbatim.

## Dependencies

- **bash** — built in on macOS / Linux; on Windows install [Git for Windows](https://git-scm.com/download/win). Hooks locate git-bash automatically through `hooks/run-hook.cmd` (deliberately avoiding WSL's bash).
- No jq — all JSON escaping is pure bash, identical behavior on all three platforms.

## Development and verification

```bash
python tests/test-plugin-metadata.py   # manifest / hooks / skills metadata
bash tests/test-hooks.sh               # hook behavior (Linux / Git Bash)
```

The metadata test also keeps per-session fixed context (the SessionStart primer plus all skill descriptions) at or below the v0.5.0 baseline. Trigger quality is calibrated from real-world feedback rather than a manual release gate.

On Windows, also run the real Windows entry point:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-windows-hook.ps1
```

GitHub Actions runs the same checks on Ubuntu and Windows.

## Credits

The discipline philosophy and the cross-platform hook mechanism (the polyglot `run-hook.cmd`, SessionStart injection, pure-bash JSON escaping without jq) come from [superpowers](https://github.com/obra/superpowers) (Jesse Vincent, MIT). This project distills that approach into a compact set of Chinese-language discipline skills and adds Windows / git-bash support.

## License

MIT — see [LICENSE](LICENSE).

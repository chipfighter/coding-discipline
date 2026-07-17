# coding-discipline

**Chinese** → [README.zh-CN.md](README.zh-CN.md)

**Guardrails, not a workflow.** Quiet on routine work; firm when a named
failure mode is at risk.

AI coding agents tend to fail in two expensive ways:

1. **They drift off-goal.** A decision is confirmed in chat, but the next
   session reads a stale spec and builds the old target.
2. **They skip steps.** They code before requirements are aligned, patch
   symptoms before finding the root cause, or claim success without current
   evidence.

`coding-discipline` is a lightweight, workflow-agnostic plugin that addresses
both:

- **Spec sync** writes confirmed goals, non-goals, constraints, and acceptance
  criteria back to the current source of truth when later sessions would
  otherwise act on stale intent.
- **Risk-triggered discipline** invokes firm engineering guardrails only when
  their conditions match: design alignment, TDD, systematic debugging,
  prioritized review, evidence-before-done, disciplined git flow, and context
  hygiene.

It does **not** replace Plan mode, launch subagents, orchestrate worktrees,
choose models, or force every task through a spec workflow. Small changes stay
small. When a risk trigger matches, the corresponding skill stays firm.

8 skills + 2 hooks. Install once, apply globally. Supports Claude Code and
Codex.

<!-- TODO(demo): record two ~30s clips and replace this comment block via the
github.com editor (drag the .mp4 files in; GitHub hosts them).

## Quiet by default, firm when it matters

Scene 1 — a routine edit: no skill fires, the change just happens.
Scene 2 — "done" is claimed without evidence: verify-before-done blocks the
claim until tests actually run.
-->

## Why this exists

The surrounding tools solve different layers:

| project | primary role |
|---|---|
| [Superpowers](https://github.com/obra/superpowers) | a complete software-development methodology and agentic workflow |
| [Spec Kit](https://github.com/github/spec-kit) / [OpenSpec](https://github.com/Fission-AI/OpenSpec) | an explicit spec-driven workflow and artifact lifecycle |
| **coding-discipline** | a small guardrail layer that preserves intent and blocks risky shortcuts without taking over the workflow |

Use it when you want more discipline than a bare coding agent, but do not want
another orchestration layer.

### Fixed cost, measured

The fixed per-session context cost of this layer is about the same as a full
workflow framework — we measured both and publish the script:

| fixed injection per session (measured 2026-07-17) | coding-discipline v0.8.0 | superpowers v6.1.1 |
|---|---|---|
| SessionStart hook payload | 1,630 chars | 3,277 chars |
| skill metadata (names + descriptions) | 3,600 chars (8 skills) | 2,279 chars (14 skills) |
| **total** | **5,230 chars (~1.3k tokens)** | **5,556 chars (~1.4k tokens)** |

Both plugins are measured with the same rules: everything the SessionStart
hook injects, plus the skill metadata the host loads for routing. Skill
bodies are excluded on both sides — they load only on trigger. Reproduce with
[experiments/context-measure/measure_fixed_context.py](experiments/context-measure/measure_fixed_context.py).

So the difference is not startup tokens; it is intervention frequency. A
workflow framework routes every conversation through its process —
brainstorming, plan documents, subagent dispatch, review loops.
coding-discipline stays out of the way until a named failure mode is at risk,
and even then it adds no subagents, no plan files, no new artifacts.

## Install

### Codex

```bash
codex plugin marketplace add chipfighter/coding-discipline
codex plugin add coding-discipline@coding-discipline
```

Open a new task after installation. The first time a hook is enabled, and
whenever it changes, Codex asks you to review it. Use `/hooks` to inspect and
trust it.

To test a local checkout, replace the first command with:

```bash
codex plugin marketplace add .
```

### Claude Code

```text
/plugin marketplace add chipfighter/coding-discipline
/plugin install coding-discipline@coding-discipline
```

The first command adds this repository as a self-hosted plugin source; the
second installs the plugin. Open a new session after installation. To test a
local checkout, replace the repository name in the first command with a local
path.

### Skills only, without hooks (Codex)

Codex supports `SKILL.md` directly:

```bash
mkdir -p ~/.agents/skills
cp -r plugins/coding-discipline/skills/* ~/.agents/skills/
```

Windows PowerShell:

```powershell
Copy-Item -Recurse "plugins\coding-discipline\skills\*" "$HOME\.agents\skills\"
```

This route omits SessionStart injection, usage counting, and guide-doc seeding.
If you want the global discipline primer, review
`plugins/coding-discipline/hooks/skill-discipline.md` and merge it into
`~/.codex/AGENTS.md` once.

## The eight skills

Each skill description defines both its trigger and its exclusions. The full
instructions load only when the skill is selected.

| skill | when it triggers |
|---|---|
| `spec-sync` | confirmed goals, non-goals, constraints, or acceptance criteria must survive across sessions, but the current source of truth is stale or missing |
| `brainstorming` | requirements have multiple reasonable interpretations, design tradeoffs matter, or a wrong change would be expensive |
| `tdd` | new or changed behavior can be verified with an automated regression test |
| `systematic-debugging` | a bug, failure, or unexpected behavior has no established root cause |
| `code-review` | changes affect coordination across modules, cross a high-risk boundary, or the user requests a review |
| `verify-before-done` | before any claim that work is complete, fixed, tested, or ready |
| `git-flow` | branching, worktrees, commits, tags, or branch wrap-up |
| `context-hygiene` | entering a project, reading project history, or resolving conflicting documentation |

The skills are intentionally short. They keep only the hard judgment rules that
models routinely skip; the harness remains responsible for ordinary planning
and execution.

## The two hooks

- **SessionStart discipline:** injects a compact, host-neutral primer that
  requires matched skills to be formally invoked, preserves instruction
  precedence, and tells the agent to answer in the user's language while
  matching the repository language for files and comments.
- **Passive local usage counting:** appends session activations to
  `~/.coding-discipline/usage.jsonl`. Claude Code also exposes per-skill
  invocations. Nothing is sent over the network.

View the local summary:

```bash
bash plugins/coding-discipline/hooks/skills-count.sh
```

Disable counting:

```bash
CD_USAGE_ENABLED=0
```

## Project guide seeding

On the first session inside a Git repository, the plugin creates an empty guide
skeleton when the target file does not already exist:

- Claude Code → `CLAUDE.md`
- Codex → `AGENTS.md`

The guide is seeded only at the repository root, including when the session
starts in a nested directory or worktree. It never overwrites an existing file.
Set `CD_SEED_AGENT_DOC=0` to disable it.

The English skeleton is intentionally sparse. Add only confirmed project facts
that cannot be inferred from the code. Agents still answer in the user's
language. The guide is shared project context, not a machine-local cache:
commit confirmed rules when the team and future sessions need them, and never
store secrets, tokens, or personal data in it.

## Honest limits

Skills are prompt-level discipline, not a deterministic policy engine. They
reduce failure probability; they cannot guarantee perfect routing or
compliance.

For stronger enforcement:

- invoke a skill explicitly when routing must not be left to the model;
- put repository-specific hard rules in that project's `CLAUDE.md` or
  `AGENTS.md`;
- put mechanical requirements in CI, lint, tests, branch protection, and
  required review.

Report false triggers and missed triggers with the repository's routing
feedback issue template. Regression cases grow from real failures rather than a
synthetic release suite.

## Dependencies

- **bash** — included on macOS and Linux. On Windows, install
  [Git for Windows](https://git-scm.com/download/win); `run-hook.cmd` locates
  Git Bash without selecting WSL's `bash.exe`.
- No `jq` — JSON escaping and local usage records use pure bash.

## Development and verification

```bash
python tests/test-plugin-metadata.py
bash tests/test-hooks.sh
```

On Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-windows-hook.ps1
```

The metadata test freezes the v0.8.0 English fixed-context baseline at 4944
characters: the SessionStart primer plus all eight skill descriptions may not
grow unless text is removed elsewhere. GitHub Actions runs the same validation
on Ubuntu and Windows.

## Credits

The discipline philosophy and cross-platform hook foundation — including the
polyglot `run-hook.cmd`, SessionStart injection, and pure-bash JSON escaping —
come from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent
(MIT). This project narrows that foundation into a workflow-agnostic guardrail
layer and adds spec synchronization, risk-triggered routing, and
Windows/Git-Bash support.

## License

MIT — see [LICENSE](LICENSE).

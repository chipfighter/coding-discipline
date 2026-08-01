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

## Why this exists

[Superpowers](https://github.com/obra/superpowers) proved that engineering
discipline can live in agent skills — this plugin even reuses its
cross-platform hook pattern (see Credits). But Superpowers is a complete
workflow: its bootstrap asks the agent to route every response, even a
clarifying question, through the skill system first.

coding-discipline starts from the opposite default. Skills stay dormant until
a named failure mode is at risk; routine work runs untouched. The fixed
context injected per session is ~1.2k tokens and cannot silently grow — a CI
test fails the build when it does. The cost that actually differs between
plugins is how often one inserts itself, and what it spawns when it does.

On top of the guardrails, this project adds a piece of its own: the spec
layer. spec-sync writes confirmed goals, non-goals, hard constraints, and
acceptance criteria back into the docs the project already has — no
proposal → approve → archive lifecycle, no new artifacts — so the next
session does not rebuild a target you already rejected.

Use it when you want more discipline than a bare coding agent, but do not
want another orchestration layer.

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

### Skills only, without hooks (Codex and other hosts)

The eight skills are plain `SKILL.md` files that conform to the
[agentskills.io](https://agentskills.io) spec — conformant `name`, a
description within the 1024-character limit, and a `license` on every file so a
copied skill still carries its terms. A CI test enforces those limits, because
Claude Code is lenient about all three and a violation would fail silently
wherever else the directory is copied.

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
  matching the repository language for files and comments. The hook emits the
  envelope each host documents — `hookSpecificOutput.additionalContext` for
  Claude Code and Codex, `additional_context` for Cursor, top-level
  `additionalContext` for Copilot — and appends only the host's own invocation
  note. Tests cover all four envelope shapes; Claude Code and Codex are the two
  used daily, so treat Cursor and Copilot as conformant-but-unproven until you
  have run them yourself.
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

Disable the primer by itself, leaving counting and guide seeding in place:

```bash
CD_PRIMER=0
```

The primer is fixed cost paid on every session, and whether it earns that cost
is a question about your workload rather than a claim this project can settle
for you. This switch is what makes it answerable: run the same tasks with it on
and off, and compare.

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

## Security

A skill is executable context: whatever it says enters an agent that already
holds your credentials and your file system. Public skill catalogues scanned in
2026 turned out to carry prompt injection and credential exfiltration in a
large minority of entries, so this plugin treats "our skills are clean" as a
claim that has to be checked rather than promised.

`tests/test-skill-safety.py` scans every shipped file for the known attack
classes — network egress, credential and private-key paths, piping into a
shell, decoded or indirect execution, and invisible or bidirectional Unicode
that hides instructions from a human reading the diff. Each rule carries a
sample it must still match, so a pattern that quietly stops working fails the
build instead of reporting success forever. CI runs it on Ubuntu and Windows.

The plugin makes no network calls and sends no telemetry. Its only write
outside your repository is the local usage log at
`~/.coding-discipline/usage.jsonl`, and the test fails if that sink ever moves
without this claim being re-checked.

```bash
python tests/test-skill-safety.py
```

## Dependencies

- **bash** — included on macOS and Linux. On Windows, install
  [Git for Windows](https://git-scm.com/download/win); `run-hook.cmd` locates
  Git Bash without selecting WSL's `bash.exe`.
- No `jq` — JSON escaping and local usage records use pure bash.

## Development and verification

```bash
python tests/test-plugin-metadata.py
python tests/test-skill-safety.py
bash tests/test-hooks.sh
```

On Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-windows-hook.ps1
```

The metadata test freezes the English fixed-context baseline at 4580
characters (4944 at v0.8.0, re-frozen after a dedup trim): the SessionStart
primer plus all eight skill descriptions may not grow unless text is removed
elsewhere. GitHub Actions runs the same validation
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

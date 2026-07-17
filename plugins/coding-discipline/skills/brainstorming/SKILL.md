---
name: brainstorming
description: Use before coding when requirements have multiple reasonable interpretations, approaches require tradeoffs, or mistakes would be costly (permissions/payments/data migration/public APIs/data structures/hard-to-revert changes). Clarify requirements and design one question at a time, then get approval before implementation. Do not trigger for a focused small change with a clear goal and approach, or for mechanical edits (copy/constants/config values).
---

**Hard rule: write no code until the design is approved.** Once this skill triggers, follow it through—the design may be only a few sentences, but it must be explained and approved first. Deciding midway that it is "actually simple" is not a reason to exit: "simple" often means unstated assumptions.

## Excuses that surface when you want to skip design
| What you tell yourself | Reality |
|---|---|
| "This is too simple to need design." | "Simple" means unstated assumptions, which are the most dangerous. A simple design may take only a few sentences, but it still needs to be explained and approved. |
| "It will be faster to think while building." | Starting from a misaligned understanding makes rework slower. Align on the direction before acting. |
| "The user probably wants X." | Do not decide for the user. Clarify one question at a time, and offer choices when possible. |

## Process
1. **Inspect the context first**: relevant files, documentation, and recent commits. Do not design in a vacuum.
2. **Ask one question at a time** to clarify the goal, constraints, and success criteria. Offer choices when possible; they are easier to answer than open-ended questions. Put only one question in each message.
3. **Split up work that is too large**: if it is really several independent subsystems, stop and help divide it into subprojects and prioritize them before detailing a large task that should be broken apart.
4. **Present 2–3 approaches with tradeoffs**: put your **recommended** option first and explain why, then list the alternatives and their costs.
5. **Present the design in sections and confirm each one**: make each section as long or short as its complexity warrants. After each section, ask "Does this look right?" before continuing.
6. **Remove features that are not needed yet (YAGNI)**: if it is not needed now, do not design it.

## After approval
Begin implementation only after the design is approved. If any part stops making sense along the way, return and clarify it.
If the design establishes a durable project decision that cannot be inferred from the code (a technology choice / hard boundary / definition of done), ask whether to record it in the project guide (`AGENTS.md` for Codex, `CLAUDE.md` for Claude Code; see context-hygiene for how). If an approved outcome or acceptance criterion from this session must persist across sessions, also ask whether to create or update the current spec, then hand that work to spec-sync.

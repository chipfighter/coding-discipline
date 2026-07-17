---
name: context-hygiene
description: Use when starting a project, reading project documentation or history, or resolving conflicts between documents. For current state, read only the latest documents designated by the project; do not proactively read archives; do not duplicate the spec; use long-term memory only for environment, people, and preferences not recorded in the repository.
---

Old documents can trace history, but they are not current facts. Models easily follow the most extensively documented old account instead of finding the latest, correct one. If the project guide document (Codex's `AGENTS.md` / Claude Code's `CLAUDE.md`) designates a current-state document and archive location, follow it.

## What to read—and what not to read
1. **For current state, read only the latest document designated by the project** (such as the top of `CHANGELOG.md` or a STATUS document). Do not treat an old version snapshot as current.
2. **Do not proactively read archives or documents marked `superseded` / deprecated.** When history is genuinely needed, search for and read the relevant passage rather than reading the entire archive.
3. When documents conflict, first follow the project's designated latest state document; if it is still unclear, ask the user. Do not choose one yourself, and never treat an archive as current.

## Do not copy another set of instructions
4. Point design work to the existing project guide document / architecture decision record (ADR) / current-state document instead of copying another spec—the copy will eventually go stale.
5. **When the reason for a direction changes, rewrite it; do not append:** retaining the old rationale invites it to be repeated and pull the work in the wrong direction.
6. **Use memory only for facts unavailable in the repository** (environment / people / preferences / lessons from past pitfalls). Read project progress from the current-state document, and record design rationale in an architecture decision record (ADR). Delete stale memory; do not archive another copy.

## Project guide documents grow over time; they are not filled in up front
When the project root has no `AGENTS.md` (Codex) or `CLAUDE.md` (Claude Code), the plugin places the corresponding empty skeleton there the first time it enters the repository. It grows by **confirming one thing and recording one line**:
- Record only things already agreed with the user and not apparent from the code (technology choices / hard boundaries / definition of done). Do not record matters still under discussion or unsettled—filling the guide up front makes later sessions treat guesses as facts.
- Whenever such a decision is finalized, proactively ask, “Should I record this in the project guide document?” Write it only after approval, one line at a time.
- If a recorded decision later changes, edit that line; do not add a conflicting line below it (the same “rewrite, do not append” rule above).

## When a document becomes obsolete
Mark it `status: superseded by XX`, move it to the archive, and use an architecture decision record (ADR) to explain why it was abandoned—so a later session does not revive and rebuild a discarded idea.

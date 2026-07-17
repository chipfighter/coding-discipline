---
name: spec-sync
description: Use in cross-session work when user-confirmed outcomes, non-goals, hard constraints, or acceptance criteria have not been written back to the current source of truth (spec), or reality conflicts with it enough that following it would be wrong; also use during wrap-up or handoff when a source of truth should exist but does not. Edit only the affected original wording; do not keep separate old and new versions. Do not trigger for work that can be completed within one session, local implementation details, verification against existing acceptance criteria, locating the source of truth, or ordinary documentation edits.
---

Iron rule: **A change confirmed in conversation must not remain only in the conversation.** If user-confirmed intent that affects future collaboration or acceptance is not written back to the source of truth in this session, the next session cannot even see that the user changed their mind—intent that was never persisted cannot be recovered.

## The decision test (the only test for whether to sync)
> If the next session or another agent read only the current source of truth, would it continue toward an outcome the user has rejected, violate a new constraint, or judge completion against stale criteria? If so, the change must be synced.

- Only changes the user has **already confirmed** belong in the spec; your own inferences and ideas still under discussion do not.
- Before deciding, read the current source of truth at most once to compare. Do not turn this into research.

## Write-back rules
1. Use the current source of truth already designated by the project—the document named by the project guide.
2. If none is designated, designate an existing Issue / PRD / ADR / status document as the current spec; **do not copy it into a second document**. If there are multiple candidates or none is obvious, ask the user to choose.
3. If nothing exists and the work genuinely spans sessions, is shared by multiple people, or would be costly to get wrong, ask whether the user wants a minimal spec (below). The user decides whether to create one; do not create one for work that can be completed within a single session.
4. After designating or creating one, put a pointer to the source of truth in the project guide document (the “where to find the current state” entry in `CLAUDE.md` / `AGENTS.md`)—**write only the pointer, not a copy of the content**—so the next session can find it.
5. **Edit only the affected original wording**: do not append separate “old decision / new decision” versions, reorder the document, or polish the whole document along the way. Replace the affected text as a whole only when the direction changes substantially; leave history to Git.
6. Do not record execution progress, next steps, or verification evidence. Those belong to the harness / Git / CI, not the spec.
7. In multi-person / multi-agent work, workers are read-only by default; the primary agent or owner maintains the spec.

## Minimal spec (five items—add no more than needed)
The current desired outcome; explicit non-goals; hard constraints; acceptance criteria for this work; confirmed unresolved questions that would block safe execution (include only questions the user has confirmed—do not promote your guesses into settled facts).

## Exceptions (do not force either case)
- **No write access to the source of truth** (for example, a PRD owned by someone else): do not overstep. State clearly what is stale and who should update it.
- **The user explicitly refuses write-back**: explain that the next session may read the old target, then comply. An old spec must never be used to block the user's latest instruction.

## Red lines
- Do not write changes to outcomes / non-goals / hard constraints / acceptance criteria into the source of truth until the user has confirmed them.
- If the implementation is verified but the source of truth is not synced, report those as two separate facts. Do not claim “the source of truth is synced” or “handoff will preserve everything.”
- Complete the sync **within this session**. Do not expect a later session to recover intent that was never persisted.

## Boundary
Which document is the current source of truth and how to read it belong to context-hygiene. Verifying completion against existing acceptance criteria belongs to verify-before-done. This skill governs one thing only: **whether the source of truth reflects the user's latest confirmed decisions.**

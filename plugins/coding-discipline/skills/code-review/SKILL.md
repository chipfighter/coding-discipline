---
name: code-review
description: Use when changes affect interactions across multiple modules, involve high-risk areas (authorization/authentication, payments/funds, data deletion/migration, public APIs/cross-service interfaces/security boundaries), or the user requests a review. Review in this order—correctness → requirements → security → simplicity → style. Verify feedback before acting; do not comply blindly or agree performatively. Unless the user asks, documentation-only changes, explicit config values, and mechanical renames do not trigger merely because of a PR or merge.
---

## Performing a review (review it yourself; delegate when worthwhile and supported)
When an independent perspective is needed and the current client supports subagents, you may delegate a review. Give the reviewer **carefully scoped context** (what changed, which requirements it should meet, and the base..head diff range), not the entire session history. Review small changes yourself; do not add agent overhead for appearances.

Review in this **priority order**. Do not dwell on a lower priority while a higher one is unresolved:
1. **Correctness**: is the logic sound; are edge cases, errors, or concurrency missing; can it crash?
2. **Requirements**: check each requirement and design point. Does the change do what was requested, and is anything missing?
3. **Security**: injection, unauthorized access, secret leakage, unvalidated input.
4. **Simplicity**: overengineering, duplication, removable dead code, features that are not needed yet.
5. **Style**: naming, consistency, readability—review these last, not first.

Use severity: fix blockers (crashes/security) immediately, fix important issues before proceeding, and note minor issues for later.

## Receiving review feedback
- **Verify before changing anything**: does this feedback apply to **this** codebase? Could it break existing behavior? Is there a reason the code is written this way? If uncertain, say, "I cannot verify X. Should I investigate, ask, or leave it for now?"
- **Do not comply blindly**: if a suggestion is wrong, lacks context, asks for something not needed yet, or conflicts with an established architecture decision, push back with **technical reasons** rather than changing it because a reviewer said so. Stop and consult someone when the conflict concerns architecture.
- **No performative agreement**: do not say "You're right!", "Good suggestion!", or "Thanks for catching that!" If you make the change, state what changed and where. If your pushback was wrong, say only, "I checked and I was wrong because X; I changed it." Do not write a long apology.
- If anything is unclear, **clarify every item before making changes**. Do not act only on the items you understand; review items are often related, and partial understanding leads to wrong changes.
- Address one item at a time, test each change, and confirm that it introduced no regressions (see verify-before-done).

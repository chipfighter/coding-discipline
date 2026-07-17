---
name: git-flow
description: Use when creating a branch, using worktrees for parallel work, committing, or wrapping up. Covers branch naming, conventional commits, short-lived branches, worktree isolation, and final merge/cleanup.
---

> Branch naming rules, protected branches, whether to merge directly or through a PR / MR, whether merging triggers CI, and **how to choose versions / who creates tags** are project-specific rules governed by this repository's `AGENTS.md` / `CLAUDE.md`. This skill provides only general discipline.

## Version / tag closeout (only for projects that manage versions with tags + CHANGELOG; **a tag is a version bookmark—whether it also means release / deployment is defined by the project guide document**)
- **Choose the version before creating the branch:** first confirm the intended tag with the owner—state the previous tag, what remains in the backlog, and whether this work is a feature or a fix, then recommend a version. **Wait for the owner's confirmation before creating the branch**; do not finish the work only to discover there is no agreed release target.
- **Follow SemVer:** major = breaking change, minor = backward-compatible feature, patch = backward-compatible fix. For 0.x, use the looser convention (minor = capability, patch = fix), and when uncertain prefer the larger bump. The project guide document defines what counts as a minor change.
- **Freeze once decided:** after the target version is confirmed, freeze its scope. New requirements arising midway **go to the backlog / next version by default**. Including one in the current version requires explicit owner approval and a clear statement of what it displaces or defers.
- **Use a component, not a version number, as the commit scope** (`feat(auth):`, not `feat(v1.2):`). Branches are deleted; commit history is not. The history remains accurate if the version changes.
- **Version closeout sequence:** complete the scope → merge the branch into the baseline → get CI green → move the CHANGELOG entry from pending into the new version → create the tag (who creates it and how are project-specific).

## Branches and commits
- Create a new branch for each development effort. **Never** edit directly on a protected main branch or someone else's branch. If the user or client has explicitly provided a working branch, keep using it instead of creating a pointless one. Keep branches short-lived: integrate them quickly rather than letting them drift.
- Use a type + short description in branch names (for example, `feat/search-pagination` or `fix/login-timeout`); follow the project's naming convention when it has one.
- Use conventional commits: `type(scope): description` (feat/fix/refactor/docs/chore…). Commit in small steps, each independently reversible.

## Parallel worktrees (when running several workstreams at once or isolating work from the current workspace)
- First check **whether you are already in an isolated workspace**. If so, do not nest another one.
- Prefer built-in worktree management in clients such as Claude Code / Codex. Do not manually run `git worktree add` and create a workspace the client cannot see; fall back to Git only when the client lacks this capability.
- Before creating a project-local worktree under `.worktrees/`, confirm that the directory is gitignored; otherwise its contents may be committed accidentally.
- After creating it, install dependencies and run the baseline tests. Report existing failures before starting work.

## Wrap-up
- **Verify that all tests pass before wrapping up** (see verify-before-done). A failing branch must not proceed to merge / PR.
- Offer **explicit choices** instead of asking an open-ended “What next?”: ① merge into the baseline branch ② push and open a PR/MR ③ keep as-is ④ discard.
- Always in this order: **merge and verify success → remove the worktree → delete the branch**. A branch still referenced by a worktree cannot be deleted; before running `git worktree remove`, `cd` back to the main repository.
- Clean up only worktrees **you created**; do not touch client-created ones. Discarding requires typed confirmation. Do not force-push unless explicitly asked.

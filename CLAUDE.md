# Project guide

## Current source of truth

Use the latest GitHub Release / tag for released state. Use the `README.md` on
`main` for the current repository state.

## What this project is

`coding-discipline` is a workflow-agnostic, two-layer guardrail plugin for AI
coding agents: spec sync preserves confirmed intent across sessions, while
risk-triggered skills prevent costly engineering shortcuts. The harness owns
speed and orchestration; skills intervene only for specific failure modes;
`spec-sync` writes confirmed goals, boundaries, and acceptance criteria back to
the current source of truth so humans and agents keep building the same thing.

The product invests only in two foundations that should remain useful as models
improve: hard guardrails against recurring judgment failures, and durable
human-agent intent alignment.

## Hard boundaries

- Do not compete with the harness orchestration layer: no subagent scheduling,
  plan-mode replacement, worktree orchestration, or model selection.
- Do not add Lite / Strict modes. Risk levels emerge from trigger boundaries.
- Each `SKILL.md` description is the only routing source. The SessionStart
  primer must not duplicate the routing table.
- Project guide files point to the current spec; they do not host an active spec.
- Create skills only around named failure modes. If a skill cannot state the
  failure it prevents, it does not belong.
- Once a skill triggers, do not soften its discipline. Risk calibration belongs
  at the trigger boundary.
- Admit a generic high-risk signal only if it stays broadly costly across
  industries and languages; project-specific risks belong in project guidance.
- Fixed injected context is zero-sum: adding text requires removing equivalent
  text elsewhere. v0.8.0 establishes a one-time 4944-character English
  baseline, frozen again after the migration.
- Regression cases grow only from real false-trigger / missed-trigger reports
  and must map to the description change they justify. Do not maintain a
  synthetic scenario suite or make one a release gate.
- The runtime, manifests, templates, issue forms, code comments, and primary
  `README.md` are English-only. `README.zh-CN.md` is the sole maintained Chinese
  translation. Agent replies still follow the user's language unless requested
  otherwise.

## Stack and directory conventions

(Not decided.)

## Definition of done by release

- v0.6.0 (trigger recalibration): cross-platform CI passes and fixed injected
  context does not exceed the v0.5.0 baseline. Trigger quality is calibrated
  from real feedback rather than a synthetic release gate.
- v0.6.1 (review without ceremony + evidence timing): CI passes; `code-review`
  no longer triggers merely because work enters a PR or merge; verification
  accepts only evidence collected after the last relevant change and strong
  enough to prove the claim.
- v0.7.0 (spec sync layer): add `spec-sync` and connect it to `brainstorming`
  and `verify-before-done`; preserve the other seven descriptions and the
  SessionStart primer; present the dual-layer positioning in both READMEs; CI
  passes with fixed injected context at 1466 characters against a 1491 budget.
- v0.8.0 (English-first global release): translate the complete active product
  surface to English without changing v0.7.0 skill behavior; make `README.md`
  the English primary entry and keep only `README.zh-CN.md` as a Chinese
  translation; freeze the English fixed-context baseline at 4944 characters;
  version both manifests as 0.8.0; all metadata, Linux hook, and Windows hook
  tests pass.

---
name: verify-before-done
description: Use before claiming "done", "fixed", "tested", or "it runs", and before committing or opening a PR or MR—no task is exempt. Accept only evidence gathered after the last relevant change and just sufficient to prove the claim; do not over-verify small changes.
---

Hard rule: **Only evidence gathered after the last relevant change to the code, files, or environment, and directly sufficient to prove the claim, counts.**
- Claiming completion without sufficient evidence = lying; running the full test suite for a typo = waste.
- You may reuse evidence just gathered, but state when it was gathered and confirm that no code was changed, nothing was pulled, and the environment was not modified afterward. If you cannot say for sure, check again.

## Required checks (before any claim of success or completion)
1. What claim must be proven? What check is just sufficient (command output / diff / artifact inspection…)?
2. Was the evidence gathered after the last relevant change? Yes—state when. No / uncertain—**check again**.
3. If you ran a command, read all output, inspect the exit code, and count failures. If you inspected a diff or artifact, state what you checked and the result.
4. Does the evidence actually prove the claim? Yes—state the conclusion together with the evidence. No—report the true status.

Skipping any step = lying, not verification.

## Could not run ≠ skipped
If a command cannot run (missing environment, broken dependencies, timeout), **verification failed**. Report that verification could not be completed and what blocked it. Do not quietly mark the step green as “skipped,” and do not misreport an environment problem as a product failure.

## None of these counts as "verified"
| Claimed evidence | Why it does not count |
|---|---|
| lint / type checks passed | This proves only that the checks pass, not that the project builds, runs, or behaves correctly. |
| A subagent reported "success" | That is its claim. Inspect the diff / actual artifact yourself. |
| The regression test passed once | This does not prove it catches the problem. In a safe, isolated way, temporarily disable this round's fix → the test must fail → restore the fix → the test must pass. Do not do this by reverting or overwriting user files. |
| "Tests are green = requirements are met" | Check each requirement explicitly; green tests alone are not enough. |
| Only part of the suite ran | This does not mean the whole suite passed. |

## Hard rules
- Do not substitute "should", "probably", or "looks right" for evidence.
- Do not celebrate ("Done!" / "Fixed!" / "Perfect!") before obtaining evidence.
- Before committing, pushing, or opening a PR or MR after an important change, pass the checks above.
- If this work includes a confirmed change that makes the current source of truth inaccurate, or the work spans sessions but still lacks a source of truth, use spec-sync before claiming it is ready for handoff. If the user explicitly refuses persistence, explain the consequence and follow their latest instruction.

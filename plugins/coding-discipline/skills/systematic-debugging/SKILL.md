---
name: systematic-debugging
description: Use before proposing a permanent fix for bugs, test failures, or unexpected behavior with an unknown root cause—mandatory when symptoms are far from the cause, a prior fix failed, or the issue crosses components. Reproduce, trace backward to the root cause, fix once at the source, and add a regression test. Do not trigger for obvious errors whose message identifies the cause (syntax/typo/missing import); fix those directly.
---

Hard rule: **do not package a guess as a permanent fix before locating the root cause.** If the user explicitly needs emergency containment, you may apply a reversible temporary mitigation first, but you must state its risks and that the root cause is not fixed, then continue investigating.

## 1. Reproduce
- Read the error message and full stack trace carefully—the answer is often there. Do not skip them. Note the line number, file, and error code.
- Establish a reliable reproduction first: which steps trigger it every time? If you cannot reproduce it reliably, gather data before proceeding. **Do not guess.**
- Inspect recent changes: git diff, recent commits, new dependencies, and configuration or environment differences.

## 2. Trace backward to the root cause
- Follow the bad value backward: where did it come from → who called something with it → continue to the source. **Fix it at the source, not at the symptom.**
- In a multi-component system (CI→build→signing, API→service→library), record what enters and leaves each boundary. Run it once to see **which layer** fails, then investigate that layer. Do not guess based on intuition.
- Find a similar working example and list every difference from the broken one. Do not assume that "this difference cannot matter."
- Example: an amount on a page has two extra decimal places. Trace it backward: the display layer receives the wrong value → it came from the API → the value read from the database is correct → the API returned cents as dollars. **Fix the API layer; do not compensate with display formatting.**

## 3. One hypothesis at a time
- Write it down: "I believe the root cause is X because Y."
- Test it with the **smallest** change, varying only one thing at a time. Do not stack new fixes on an unverified one.
- If you do not understand X, say so. Do not pretend and guess.

## 4. Fix the root + add a regression test
- Write a failing test that reproduces the bug before fixing it (see tdd).
- Make **one** fix in one place. Do not opportunistically refactor or change anything else.
- Verify that the test passes, nothing else broke, and the problem is actually gone (see verify-before-done).

## Three failed fixes = stop and question the architecture
If every fix creates a new problem elsewhere or requires a "large refactor," the problem is not the hypothesis but the architecture. **Do not attempt a fourth fix.** Stop and discuss whether the design itself is fundamentally wrong.

## No random attempts: when these thoughts appear, stop and return to Step 1
| Thought | What to do |
|---|---|
| "Apply a quick fix now and investigate the root cause later." | There is no later—once the symptom changes, you will stop investigating. Trace it to the root cause before changing anything. |
| "Change this and see whether it works." | That is guessing. First write, "I believe the root cause is X because Y," then test it with the smallest change. |
| "It is probably X; just fix it." | Reaching a conclusion before tracing the data flow is a gamble. Follow the bad value to its source first. |
| "Put several changes in and run it." | Change only one variable at a time, or a passing result will not tell you which change mattered. |
| "Two attempts failed; maybe one more will work." | Stop. A third attempt probably means the direction is wrong. Return to Step 1 or ask someone else. |

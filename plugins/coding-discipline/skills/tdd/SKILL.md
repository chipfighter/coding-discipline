---
name: tdd
description: Use before implementation when behavior can be verified by automated tests and regression coverage has clear value. For bugs with an unknown root cause, use systematic-debugging first, then return for red-green. Follow red-green-refactor—write a failing test first, add only enough code to pass it, then refactor. Do not trigger for documentation, configuration, copy-only, or styling changes with no testable behavior.
---

Hard rule: **write no implementation code without a test that failed first.**
Did you just write the implementation in this turn without delivering it? Remove it and restart from the test—do not keep it as a "reference" or look at it while adding tests.
**But never delete the user's existing code or someone else's workspace changes**: when working with an existing implementation, add tests that record and protect its current behavior before making the smallest change.

## Excuses to stop as soon as they appear
| What you tell yourself | Reality |
|---|---|
| "Write the implementation first and add tests later." | Tests written afterward to match the implementation only prove that "the code does what it does," not that it is correct. |
| "Keep this as a reference; do not really remove it." | The time is already spent; it is a sunk cost. If you keep it, you will shape the tests around it. Remove it (only if you wrote it this turn; never delete the user's existing code). |
| "It is too simple to be worth testing." | "Simple" means an assumption you have not stated, which is exactly where failures happen. |

## Red → Green → Refactor
1. **Red**: write the smallest failing test for one behavior. Give it a name that says what it tests, and test real code rather than mocks (use mocks only when unavoidable).
2. **Verify red (you must run it)**: watch it **fail**, specifically **because the behavior is not implemented yet**—not because of a typo, bad import, or syntax error.
   - It passes immediately = you are testing behavior that already exists. The test has no value; rewrite it.
   - The program errors instead of failing an assertion = fix the error and rerun until it "fails correctly."
3. **Green**: write the **minimum code needed to make it pass**. Do not slip in features that are not needed yet or change anything else.
4. **Verify green (you must run it)**: the test passes, every other test still passes, and the output is clean (no errors or warnings). If it fails, change the code, not the test.
5. **Refactor**: only after everything is green—remove duplication, improve names, extract functions. Keep the suite green throughout and add no new behavior.
6. For the next behavior, return to red.

## Bugs also follow red-green
Write a failing test that **reproduces the bug** before fixing it. This test proves the fix and guards against recurrence. (See systematic-debugging for finding the root cause.)

## A small example (adding email format validation)
1. **Red**: first assert that `is_valid_email("a@b.com")` is true and `is_valid_email("nope")` is false. The function does not exist yet; run the test and see it fail because the function is undefined, not because of a typo.
2. **Green**: write the smallest implementation (one regular expression) that makes both assertions pass. Do not add support for a pile of edge cases.
3. **Refactor**: extract constants or rename things only after everything is green; keep it green throughout.

## These are design warnings, not testing difficulties
- A test is hard to write = the interface is hard to use. Simplify the interface.
- Everything requires a mock = coupling is too tight. Decouple it (dependency injection).
- Setup is huge = extract helpers; if it remains complex, simplify the design.

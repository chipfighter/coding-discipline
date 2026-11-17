---
name: tdd
description: Use red-green-refactor when the user explicitly asks for test-driven development or the project specifies it for the current change.
disable-model-invocation: true
license: MIT
---

1. Add or adapt the smallest test that expresses the expected behavior. Run it against the baseline and establish that it fails for the intended reason. For a regression, use the actual failing scenario when practical.
2. Make the smallest implementation change that satisfies the behavior. Rerun the test and the relevant existing checks.
3. Refactor if it improves the result, then rerun the relevant checks on the final change.

If implementation already exists, preserve it and use a safe baseline or an isolated comparison to check that the test distinguishes the behavior. When the baseline cannot be run, report what was verified.

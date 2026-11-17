---
name: systematic-debugging
description: Use to investigate a failure whose cause is unclear, crosses component boundaries, or persists after a previous fix. Straightforward errors with an established cause can be fixed directly.
license: MIT
---

1. Capture the failing behavior with a small reproduction. If it is intermittent or unavailable, use logs, traces, or a comparison with a known-good run, and state the limits of that evidence.
2. Trace the failure back to the component that introduces it. Check inputs and outputs at boundaries and use the smallest check that can distinguish plausible causes. Revisit the hypothesis when a fix fails.
3. Fix the cause and verify the original failure against the final change. Add a focused regression test if existing coverage would miss the failure and the test can reproduce it reliably.

For urgent containment, use a reversible mitigation within the authorized scope. State what it contains and which cause remains unconfirmed.

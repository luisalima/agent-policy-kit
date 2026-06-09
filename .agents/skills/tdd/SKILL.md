---
name: tdd
description: Use before writing source code for behavior with an assertable contract. Do not use for pure formatting, docs-only edits, or declared exploratory spikes.
---

# TDD Discipline

Walk the TDD cycle for the current task:

1. Identify the behavior to assert. If unclear, ask before proceeding.
2. Write the failing test first. Show what it asserts and why.
3. Run the suite. Confirm the new test fails for the right reason, not a typo or import error. If it passes immediately, stop and reassess the test.
4. Write the minimum source change to make it pass. No extras.
5. Run the suite again. Confirm green.
6. Keep the change focused.

## Spike Exception

If the behavior is unknown, such as UI layout, an unfamiliar API, or prompt engineering:

1. Declare the spike up front: `Spike to learn X; I will discard and TDD after.`
2. Isolate it from the production change.
3. Show the discard before the real implementation lands.

An undeclared deviation is skipped tests, not a spike.

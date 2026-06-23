---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T10
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T10. Add explicit never-weaken-tests rule

## Objective
`proposal.md` mapped "never weaken tests" as implicit in "tests assert
observable behavior", but it is not implicit: nothing forbids editing an
assertion, adding a skip, or deleting a test to get a green suite. This is one
of the most important always-on rules for coding agents.

## What we need to extract / do
- Add an explicit dispatch-table rule: never weaken, skip, or delete a failing
  test to make the suite pass; fix the code or stop and ask.

## Output
Updated `templates/AGENTS.md`.

## Dependencies
None.

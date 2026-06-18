---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T11
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T11. Add scope-discipline rule

## Objective
Nothing in the policy says to keep the diff minimal and on-task. Drive-by
refactors, unrelated cleanups, and reformatting untouched files are among the
most common coding-agent failure modes. TDD's "no extras" only covers the
make-it-pass step.

## What we need to extract / do
- Add an always-on dispatch-table rule: keep changes minimal and on-task; no
  drive-by refactors, reformatting, or unrelated cleanups; propose follow-up
  tasks instead.

## Output
Updated `templates/AGENTS.md`.

## Dependencies
None.

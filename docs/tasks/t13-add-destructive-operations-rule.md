---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T13
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T13. Add destructive-operations rule

## Objective
Nothing forbids force-pushes, history rewriting, `git reset --hard`, bulk
deletes, or destructive migrations without approval. The done skill checks
"on a working branch" only at the end, after the damage window.

## What we need to extract / do
- Add an always-on dispatch-table rule: never run destructive or
  history-rewriting operations without explicit approval.

## Output
Updated `templates/AGENTS.md`.

## Dependencies
None. Hard enforcement is tracked separately in Q1 (hooks).

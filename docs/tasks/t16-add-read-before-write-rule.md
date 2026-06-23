---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T16
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T16. Add read-before-write rule

## Objective
`proposal.md` row 7 deliberated a "read before write" rule and it was dropped.
It is cheap and high-value: agents that modify files without reading them
break conventions and overwrite local intent.

## What we need to extract / do
- Add an always-on dispatch-table rule: read a file and follow its existing
  conventions before modifying it.

## Output
Updated `templates/AGENTS.md`.

## Dependencies
None.

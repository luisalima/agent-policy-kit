---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T9
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T9. Add dispatch triggers for slice and spike skills

## Objective
The `slice` and `spike` skills are installed but unreachable: the dispatch table
in `templates/AGENTS.md` never references them, so agents following the policy
will never load them. `spike` is only reachable indirectly via the tdd skill's
body text.

## What we need to extract / do
- Add a dispatch line for `slice` (before planning implementation).
- Add a dispatch line for `spike` (when behavior is unknown and exploration is
  needed before TDD).

## Output
Updated `templates/AGENTS.md` dispatch table.

## Dependencies
None.

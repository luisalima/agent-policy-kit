---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T14
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T14. Add always-on secrets rule

## Objective
The only secrets check is "no secrets staged" in the done checklist, which
fires once at the end. The rule needs to be continuous: never write
credentials into tracked files or logs in the first place.

## What we need to extract / do
- Add an always-on dispatch-table rule: never write secrets or credentials
  into tracked files, command output, or logs; use the environment or the
  repo's secret mechanism.

## Output
Updated `templates/AGENTS.md`.

## Dependencies
None. Hard enforcement is tracked separately in Q1 (hooks).

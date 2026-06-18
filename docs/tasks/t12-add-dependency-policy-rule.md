---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T12
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T12. Add dependency policy rule

## Objective
The linters skill forbids adding dependencies for linting, but there is no
general rule. Agents add packages casually; this is also the kit's
supply-chain story, which matters given the security skill track.

## What we need to extract / do
- Add an always-on dispatch-table rule: do not add, upgrade, or replace a
  dependency without explicit approval, and justify fit, maintenance, and
  license when proposing one.

## Output
Updated `templates/AGENTS.md`.

## Dependencies
None.

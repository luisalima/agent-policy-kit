---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T20
deliverable: policy
created: 2026-06-11
output: .agents/skills/threat-model/SKILL.md
---

# T20. Move threat-model output location under docs/

## Objective
The threat-model skill writes `<repo-or-path-name>-threat-model.md` to the
repo root. The kit's other durable artifacts live under `docs/`
(`docs/tasks/`), so threat models should follow the same convention.

## What we need to extract / do
- Change the default output location in
  `.agents/skills/threat-model/SKILL.md` to
  `docs/threat-models/<repo-or-path-name>.md`.

## Output
Updated `.agents/skills/threat-model/SKILL.md`.

## Dependencies
None.

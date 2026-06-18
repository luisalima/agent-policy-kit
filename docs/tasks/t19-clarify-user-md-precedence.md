---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T19
deliverable: policy
created: 2026-06-11
output: templates/AGENTS.md
---

# T19. Clarify USER.md vs SKILL.md precedence

## Objective
The dispatch table says to read `USER.md` beside `SKILL.md` but not which wins
when they conflict. Since USER.md carries local intent, it should take
precedence over the package-managed SKILL.md.

## What we need to extract / do
- Extend the existing USER.md dispatch line: when the two conflict, USER.md
  wins.
- Keep the exact phrase "also read `USER.md` in the same skill directory"
  intact; `scripts/test-install.sh` asserts it.

## Output
Updated `templates/AGENTS.md`.

## Dependencies
None.

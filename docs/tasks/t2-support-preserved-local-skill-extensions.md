---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T2
deliverable: installer
created: 2026-06-11
links: []
output: scripts/install.sh, scripts/test-install.sh, README.md, CONTRIBUTING.md, templates/AGENTS.md
---

# T2. Support preserved local skill extensions

## Objective
Give users a safe customization point for installed skills without editing
package-managed `SKILL.md` files that are refreshed on update.

## What we need to extract / do
- Decide the extension filename and location, such as `USER.md` inside each installed skill directory.
- Update bundled skill guidance so agents know to consult the local extension file when present.
- Ensure installer refresh preserves user-authored extension files or documents a non-overwritten adjacent location.
- Add tests proving local extension content survives skill refresh.
- Document that bundled `SKILL.md` files are package-managed and overwritten on update.

## Done when
- Users have a documented local skill customization path that is not overwritten by normal installs.
- Installer tests prove local extension content survives re-running `scripts/install.sh`.
- README or contributing docs explain the ownership boundary.

## Output
Updated installer behavior, tests, and user-facing docs.

## Dependencies
T1 is recommended first so preserved files are handled by the final atomic refresh flow.

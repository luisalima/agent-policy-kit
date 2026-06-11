---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T1
deliverable: installer
created: 2026-06-11
links: []
output: scripts/install.sh, scripts/test-install.sh
---

# T1. Make skill refresh atomic

## Objective
Make installer skill updates resilient so a failed refresh cannot leave a
previously installed skill missing or half-copied.

## What we need to extract / do
- Change skill directory refresh to copy into a temporary sibling directory first.
- Replace the destination only after the copy succeeds.
- Clean up temporary directories on both success and failure.
- Add an installer test that simulates a copy failure and proves the previous installed skill remains intact.

## Done when
- Re-running the installer refreshes managed skill directories through an atomic staging path.
- A simulated copy failure exits non-zero without deleting or corrupting the previous installed skill.
- `./scripts/test-install.sh` and `shellcheck scripts/*.sh` pass.

## Output
Updated `scripts/install.sh` and `scripts/test-install.sh`.

## Dependencies
Current skill-refresh behavior that replaces managed skill directories on install.

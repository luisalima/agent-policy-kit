---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T4
deliverable: release
created: 2026-06-11
links: []
output: scripts/release.sh, scripts/test-release.sh, .github/workflows/ci.yml, CONTRIBUTING.md
---

# T4. Make release script run readiness gates

## Objective
Move the release checklist from documentation-only guidance into executable
release safety checks.

## What we need to extract / do
- Update `scripts/release.sh` to run required validation before creating a tag.
- Include skill validation, installer tests, ShellCheck, README pinned-tag validation, and changelog entry validation.
- Keep clear failure messages so a releaser knows what to fix.
- Preserve current clean-tree, tag-exists, and GitHub CLI checks.

## Done when
- `scripts/release.sh vX.Y.Z` fails before tagging if required local gates fail.
- The checks cover the release checklist in `CONTRIBUTING.md`.
- Release script tests or focused shell tests cover at least one readiness-gate failure.

## Output
Updated `scripts/release.sh` and related tests/docs.

## Dependencies
T3 should land first if the release script validates against a version source.

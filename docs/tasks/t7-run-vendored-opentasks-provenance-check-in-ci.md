---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T7
deliverable: provenance
created: 2026-06-11
links: []
output: .github/workflows/opentasks-provenance.yml, scripts/test-provenance-workflow.sh, .github/workflows/ci.yml, CONTRIBUTING.md
---

# T7. Run vendored opentasks provenance check in CI

## Objective
Ensure vendored `opentasks` drift is caught automatically instead of relying on
contributors to run the provenance helper manually.

## What we need to extract / do
- Add `./scripts/diff-opentasks-upstream.sh` to CI.
- Decide whether CI should run the networked provenance check on every push/PR or only in a scheduled/manual job.
- If needed, split fast local validation from networked upstream verification.
- Document the expected failure mode when upstream and vendored content differ.

## Done when
- CI runs an appropriate vendored provenance check.
- The check fails when `.agents/skills/opentasks` differs from the commit recorded in `THIRD_PARTY.md`.
- Local contributor docs mention when to run the provenance check.

## Output
Updated CI workflow and any supporting docs.

## Dependencies
Existing `scripts/diff-opentasks-upstream.sh`.

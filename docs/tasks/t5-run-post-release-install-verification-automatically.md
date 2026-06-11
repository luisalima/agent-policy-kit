---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T5
deliverable: release
created: 2026-06-11
links: []
output: .github/workflows/post-release-install.yml, scripts/test-post-release-workflow.sh, .github/workflows/ci.yml
---

# T5. Run post-release install verification automatically

## Objective
Catch broken public release installs as soon as a GitHub release is published,
not only when someone manually dispatches the workflow.

## What we need to extract / do
- Add a `release: published` trigger to the post-release install workflow.
- Pass the published tag into `scripts/test-release-install.sh`.
- Keep the existing `workflow_dispatch` path for manual reruns.
- Confirm the script still verifies the public README one-liner exactly as documented.

## Done when
- Publishing a GitHub release automatically runs the documented install verification for that release tag.
- Manual dispatch still works for a selected tag.
- Workflow syntax is valid and local release-install script validation passes.

## Output
Updated `.github/workflows/post-release-install.yml`.

## Dependencies
Existing `scripts/test-release-install.sh`.

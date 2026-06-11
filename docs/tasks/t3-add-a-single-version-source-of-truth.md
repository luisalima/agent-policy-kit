---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T3
deliverable: release
created: 2026-06-11
links: []
output: VERSION, scripts/validate-version.sh, scripts/test-version.sh, scripts/test-release-install.sh, scripts/release.sh, .github/workflows/ci.yml, README.md, CONTRIBUTING.md
---

# T3. Add a single version source of truth

## Objective
Prevent release tag drift across README examples, workflow defaults, changelog
entries, release scripts, and tests.

## What we need to extract / do
- Add a single version source, such as a `VERSION` file.
- Update scripts and docs checks to read or validate against that source.
- Add a validation gate that fails when pinned README tag, changelog entry, or workflow defaults drift from the version source.

## Done when
- `v0.1.0` or the next release version is defined in one authoritative place.
- CI or a local validation script detects inconsistent release-version references.
- Existing install and release tests continue to pass.

## Output
Version source file plus validation updates.

## Dependencies
None.

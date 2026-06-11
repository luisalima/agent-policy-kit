---
status: done
started: 2026-06-11
closed: 2026-06-11
type: task
id: T6
deliverable: installer
created: 2026-06-11
links: []
output: scripts/install.sh, scripts/test-install.sh
---

# T6. Tighten managed block validation

## Objective
Make managed block parsing reject ambiguous marker layouts before the installer
writes anything.

## What we need to extract / do
- Require each managed file to contain either zero managed blocks or exactly one well-ordered block.
- Reject multiple start/end marker pairs unless explicit support is added.
- Reject reversed, nested, or otherwise ambiguous marker ordering.
- Add smoke tests for mismatched markers, duplicate blocks, and reversed marker order.

## Done when
- The installer exits before writes for malformed, duplicate, or badly ordered managed blocks.
- Tests prove existing files and skill directories are not partially rewritten on those failures.
- Existing replacement and append behavior still works for valid files.

## Output
Updated managed-block validation and installer tests.

## Dependencies
Current malformed-block preflight test.

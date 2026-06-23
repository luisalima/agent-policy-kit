---
status: done
started: 2026-06-18
closed: 2026-06-18
type: task
id: T21
deliverable: policy
created: 2026-06-18
links:
  - q1-hooks-enforcement-build-or-descope.md
  - ../adr/ADR-001-opt-in-hook-enforcement.md
output: scripts/hooks/check_git_push.py, scripts/hooks/check_secret_edit.py, scripts/merge_hook_config.py, scripts/test-hooks.sh, scripts/install.sh, scripts/test-install.sh, scripts/release.sh, .github/workflows/ci.yml, README.md, CONTRIBUTING.md, proposal.md, docs/adr/ADR-001-opt-in-hook-enforcement.md
---

# T21. Implement opt-in hook enforcement

## Objective
Build the hard-enforcement layer from `proposal.md` as an opt-in `--with-hooks`
installer flag (decision recorded in Q1 / ADR-001). Default installs stay
soft-policy-only; `--with-hooks` adds runtime guards backing the T13
(destructive ops) and T14 (secrets) rules.

## What we need to extract / do
- Add `scripts/hooks/check_git_push.py` (block force-push) and
  `scripts/hooks/check_secret_edit.py` (block writing high-confidence secrets).
- Add a `--with-hooks` flag to `scripts/install.sh` that copies the hook
  scripts into the target and merges hook config into `.claude/settings.json`
  (Claude) and `.codex/hooks.json` (Codex), idempotently and without clobbering
  existing config.
- Require `python3` when `--with-hooks` is set; error early if missing.
- Add `scripts/test-hooks.sh` (hook behavior + py_compile) and extend
  `scripts/test-install.sh` with `--with-hooks` coverage; wire both into CI.
- Update README, CONTRIBUTING, and the proposal.md hooks section.

## Output
Hook scripts, installer flag, merge helper, tests, CI wiring, and docs.

## Dependencies
Q1 decision (done). Builds on the T13/T14 soft rules in the same branch.

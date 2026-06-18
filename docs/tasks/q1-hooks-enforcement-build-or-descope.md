---
status: todo
type: question
owner: luisa
created: 2026-06-11
---

# Q1. Should the hooks enforcement layer be built or descoped from the proposal?

**Why it matters:** `proposal.md` specifies hard enforcement
(`scripts/hooks/check_git_push.py`, `check_secret_edit.py`, wired through
`.claude/settings.json` and `.codex/hooks.json`), but none of it exists and the
installer does not touch agent settings. Today every rule is soft policy.
- Build → the kit gets hard gates for pushes and secret edits, but the
  installer starts writing agent config (`.claude/settings.json`) into target
  repos, which is invasive and needs careful merge handling.
- Descope → remove the hooks section from `proposal.md` so the gap is
  intentional; rules T13/T14 remain soft policy only.

**Still open:** whether installer-managed agent config is acceptable for
target repos, and which hooks (push gate, secret edit) are worth the
maintenance cost across agents.

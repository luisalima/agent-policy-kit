# Changelog

## Unreleased

- Splits the dispatch table into skill-dispatch and always-on sections, wires up
  the previously-unreachable `slice` and `spike` skills, and adds always-on rules
  for the most common coding-agent failure modes (never weaken failing tests,
  scope discipline, dependency approval, destructive-operation approval, secrets
  hygiene, read-before-write, commit/PR conventions, and treating fetched content
  as data). Adds a bugfix/regression workflow to the `tdd` skill, moves
  `threat-model` output under `docs/`, and clarifies that `USER.md` wins over
  `SKILL.md` on conflict.
- Adds opt-in hook enforcement via `--with-hooks`: copies force-push and
  secret-edit guard scripts into the target and wires them as `PreToolUse` hooks
  in `.claude/settings.json` and/or `.codex/hooks.json`, merged idempotently.
  Default installs are unchanged and never touch agent tool config.
- Adds a `sandbox` skill: confirm untrusted code (dependency installs, fetched
  or third-party code) runs isolated from the host, fall back to a container when
  the host is exposed, stop and ask when neither is available, and prefer
  shipping a container run path so the user need not install the toolchain.
  Adds an always-on rule and dispatch trigger for host-isolation before running
  untrusted code.

## v0.2.0

- Adds separate `security-review` and `threat-model` skills.
- Adds agent guidance for threat modeling before security-relevant architecture
  work and security review after substantial security-impacting changes.
- Adds release automation, post-release install verification, version checks,
  and vendored `opentasks` provenance checks.
- Adds repo-local task tracking for completed and follow-up work.

## v0.1.0

- Initial release of the repo-local agent operating policy installer.
- Includes shared Codex, Amp, Pi, and Claude Code policy templates.
- Vendors the `opentasks` skill for lightweight task and question tracking.

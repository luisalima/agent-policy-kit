# Changelog

## Unreleased

- Adds a `sandbox` skill: confirm untrusted code (dependency installs, fetched
  or third-party code) runs isolated from the host, fall back to a container when
  the host is exposed, stop and ask when neither is available, and prefer
  shipping a container run path so the user need not install the toolchain.
- Adds an always-on rule and dispatch trigger for host-isolation before running
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

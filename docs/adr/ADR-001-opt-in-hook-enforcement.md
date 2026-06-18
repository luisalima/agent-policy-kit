## ADR-001: Opt-in hook enforcement

**Date:** 2026-06-18
**Status:** Accepted

### Context

The kit's rules are soft policy: text in `AGENTS.md`/`CLAUDE.md` and the skills
that an agent is asked to follow. Nothing mechanically stops an agent from
force-pushing or writing a secret into a tracked file, even though T13 and T14
forbid both. `proposal.md` described a hard-enforcement layer (hook scripts
wired through `.claude/settings.json` and `.codex/hooks.json`) but it was never
built.

Hooks only run if they are wired into each agent's per-repo config file. Making
them work therefore means the installer starts writing into a target repo's
tool configuration — a file that controls agent behavior repo-wide and may
already hold the user's own hooks. Today the installer is deliberately gentle:
it touches only its own clearly-marked managed block in `AGENTS.md`/`CLAUDE.md`
and never agent config.

### Decision

Build the hooks, but behind an opt-in `--with-hooks` installer flag. Default
installs are unchanged and never touch agent tool config. Only `--with-hooks`
copies the hook scripts into the target and merges hook entries into
`.claude/settings.json` (Claude) and `.codex/hooks.json` (Codex). The merge is
idempotent and preserves any pre-existing config; a malformed existing config
aborts rather than being overwritten. `python3` is required when the flag is
set.

### Alternatives considered

- **Always-on:** every install wires hooks. Rejected — too invasive to force on
  every adopter, and it makes the installer's config-merge the critical path for
  all installs.
- **Descope:** delete the hooks from the proposal and stay soft-policy-only.
  Rejected — gives up a meaningful safety backstop for the destructive-ops and
  secrets rules, which is notable given the kit ships a security skill track.
- **Opt-in flag (chosen):** preserves the gentle default and the soft-policy
  story while giving adopters who want hard enforcement a supported path.

### Consequences

- Default behavior and existing installs are unaffected; the gentle-installer
  guarantee holds unless a user opts in.
- Opting in adds a `python3` runtime dependency and makes the installer manage
  JSON config, including idempotent re-runs and merge-vs-clobber handling.
- Claude and Codex hook formats diverge, so each is wired separately. Amp/Pi
  receive the scripts but no wiring; their hook mechanisms are out of scope.
- The Codex hook runtime contract (non-zero exit blocks the tool call) is
  assumed to match Claude Code's; this should be verified against Codex before
  relying on it for enforcement.

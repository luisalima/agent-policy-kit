# agent-policy-kit

Repo-local operating policy and skills for coding agents.

This package installs one shared agent policy and skill set into a project so
Codex, Amp, Pi, and Claude Code can use the same workflows.

## Install Into A Repo

One-liner clone + install into the current repo from the latest release:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 --branch v0.2.0 https://github.com/luisalima/agent-policy-kit.git "$tmp/agent-policy-kit" && "$tmp/agent-policy-kit/scripts/install.sh" --target .
```

To install from `main` instead:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/luisalima/agent-policy-kit.git "$tmp/agent-policy-kit" && "$tmp/agent-policy-kit/scripts/install.sh" --target .
```

From this checkout:

```bash
./scripts/install.sh --target /path/to/repo
```

Install only selected agent layouts:

```bash
./scripts/install.sh --target /path/to/repo --codex
./scripts/install.sh --target /path/to/repo --amp
./scripts/install.sh --target /path/to/repo --pi
./scripts/install.sh --target /path/to/repo --claude
```

Flags can be combined:

```bash
./scripts/install.sh --target /path/to/repo --pi --claude
```

Opt in to enforcement hooks (off by default):

```bash
./scripts/install.sh --target /path/to/repo --claude --with-hooks
```

See [Enforcement Hooks](#enforcement-hooks-opt-in) below for what this installs.

Re-run the installer to update already installed skill folders:

```bash
./scripts/install.sh --target /path/to/repo
```

## What Gets Installed

Default install:

```text
AGENTS.md
CLAUDE.md
.agents/skills/<skill>/SKILL.md
.agents/skills/<skill>/USER.md (optional local extension)
.claude/skills/<skill>/SKILL.md
.claude/skills/<skill>/USER.md (optional local extension)
```

Agent mapping:

- Codex: `AGENTS.md` + `.agents/skills/`
- Amp: `AGENTS.md` + `.agents/skills/`
- Pi: `AGENTS.md` + `.agents/skills/`
- Claude Code: `CLAUDE.md` + `.claude/skills/`

The installer does not overwrite existing `AGENTS.md` or `CLAUDE.md` files. It
appends or updates only the managed `agent-policy-kit` block when needed.
Installed skill folders are refreshed on every run so targets receive skill
updates from the package. Bundled `SKILL.md` files are package-managed and may
be overwritten during refresh. Put local skill instructions in `USER.md` beside
the installed `SKILL.md`; the installer preserves that file on normal installs.

## Included Skills

- `opentasks`: upstream skill from `https://github.com/luisalima/opentasks-skill`
  for managing `docs/tasks/` task and question tracking.
- `linters`: conservative workflow for adding or improving project-appropriate lint commands.
- `security-review`: focused security review after substantial
  security-impacting implementation changes.
- `threat-model`: threat modeling before security-relevant architecture work.
- `sandbox`: confirm untrusted code runs isolated from the host (container
  fallback when not sandboxed) and ship a container run path for the user.
- `tdd`: test-first implementation workflow.
- `done`: definition-of-done checklist.
- `adr`: architectural decision record workflow.
- `spike`: declared exploratory-work workflow.
- `slice`: vertical-slice planning workflow.

## Enforcement Hooks (Opt-In)

By default the policy is advisory: the rules in `AGENTS.md`/`CLAUDE.md` are
instructions an agent is asked to follow, and the installer never touches agent
tool configuration. Pass `--with-hooks` to add hard enforcement for two of the
always-on rules:

- `scripts/hooks/check_git_push.py` blocks `git push --force` /
  `--force-with-lease` (backs the destructive-operations rule).
- `scripts/hooks/check_secret_edit.py` blocks writes that contain a
  high-confidence secret such as a private key or cloud access key (backs the
  secrets rule).

`--with-hooks` copies those scripts into the target's `scripts/hooks/` and wires
them in as `PreToolUse` hooks:

- Claude Code: merged into `.claude/settings.json` (requires `--claude`).
- Codex: merged into `.codex/hooks.json` (requires `--codex`/`--amp`/`--pi`).

The merge is idempotent and preserves any existing config and unrelated hooks; a
config file that is not valid JSON aborts the install rather than being
overwritten. `python3` must be on `PATH`. Amp and Pi receive the hook scripts
but no wiring — their hook mechanisms are out of scope. The guards are
defense-in-depth, not airtight: they bias toward low false positives and allow
inputs they cannot parse.

## After Install

In the target repo, run the `opentasks` bootstrap command if you want durable
task/question tracking:

```text
/opentasks bootstrap
```

For Pi, invoke the same skill as:

```text
/skill:opentasks bootstrap
```

Use the security skills at different points in the work:

```text
/threat-model <scope>
/security-review <branch or diff>
```

Threat modeling is intended before architecture work that changes trust
boundaries, auth, privileged automation, deployment topology, sensitive data
flows, or third-party integrations. Security review is intended after
substantial implementation work with plausible security impact.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). CI runs installer smoke tests,
`git diff --check`, skill metadata validation, release-version validation, and
ShellCheck.

## License

MIT. See [LICENSE](LICENSE).

# agent-policy-kit

Repo-local operating policy and skills for coding agents.

This package installs one shared agent policy and skill set into a project so
Codex, Amp, Pi, and Claude Code can use the same workflows.

## Install Into A Repo

One-liner clone + install into the current repo from the latest release:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 --branch v0.1.0 https://github.com/luisalima/agent-policy-kit.git "$tmp/agent-policy-kit" && "$tmp/agent-policy-kit/scripts/install.sh" --target .
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
- `tdd`: test-first implementation workflow.
- `done`: definition-of-done checklist.
- `adr`: architectural decision record workflow.
- `spike`: declared exploratory-work workflow.
- `slice`: vertical-slice planning workflow.

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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). CI runs installer smoke tests,
`git diff --check`, skill metadata validation, release-version validation, and
ShellCheck.

## License

MIT. See [LICENSE](LICENSE).

# Agent Operating Policy

Repo-local operating policy and skills for coding agents.

This package is designed to be copied into any project so both Codex and Claude
Code can use the same lightweight policy and the same `opentasks` workflow.

## Install Into A Repo

From this checkout:

```bash
./scripts/install.sh --target /path/to/repo
```

Install only one agent layout:

```bash
./scripts/install.sh --target /path/to/repo --codex-only
./scripts/install.sh --target /path/to/repo --claude-only
```

Replace an already installed skill folder:

```bash
./scripts/install.sh --target /path/to/repo --force
```

The installer:

- creates or appends `AGENTS.md`
- creates or appends `CLAUDE.md`
- installs `.agents/skills/opentasks/` for Codex
- installs `.claude/skills/opentasks/` for Claude Code

It does not overwrite existing `AGENTS.md` or `CLAUDE.md` files. It appends the
missing section when needed.

## Included Skills

- `opentasks`: upstream skill from `https://github.com/luisalima/opentasks-skill`
  for managing `docs/tasks/` task and question tracking.

The proposal also describes future skills (`tdd`, `done`, `adr`, `spike`,
`slice`), but those are not packaged yet.

## After Install

In the target repo, run:

```text
/opentasks bootstrap
```

That initializes `docs/tasks/README.md` and `docs/tasks/TASK_INDEX.md`.
# agent-policy-kit

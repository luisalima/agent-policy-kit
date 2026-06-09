# agent-policy-kit

Repo-local operating policy and skills for coding agents.

This package installs one shared agent policy and skill set into a project so
Codex, Amp, Pi, and Claude Code can use the same workflows.

## Install Into A Repo

One-liner clone + install into the current repo from `main`:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/luisalima/agent-policy-kit.git "$tmp/agent-policy-kit" && "$tmp/agent-policy-kit/scripts/install.sh" --target .
```

For a pinned release, add `--branch <tag>`:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 --branch v0.1.0 https://github.com/luisalima/agent-policy-kit.git "$tmp/agent-policy-kit" && "$tmp/agent-policy-kit/scripts/install.sh" --target .
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

Replace already installed skill folders:

```bash
./scripts/install.sh --target /path/to/repo --force
```

## What Gets Installed

Default install:

```text
AGENTS.md
CLAUDE.md
.agents/skills/<skill>/SKILL.md
.claude/skills/<skill>/SKILL.md
```

Agent mapping:

- Codex: `AGENTS.md` + `.agents/skills/`
- Amp: `AGENTS.md` + `.agents/skills/`
- Pi: `AGENTS.md` + `.agents/skills/`
- Claude Code: `CLAUDE.md` + `.claude/skills/`

The installer does not overwrite existing `AGENTS.md` or `CLAUDE.md` files. It
appends the missing policy section when needed. Existing skill folders are kept
unless `--force` is used.

## Included Skills

- `opentasks`: upstream skill from `https://github.com/luisalima/opentasks-skill`
  for managing `docs/tasks/` task and question tracking.
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

## Publish A Release

Commit and push changes first, then run:

```bash
./scripts/release.sh v0.1.0 --notes "Initial release"
```

The release script:

- requires a clean working tree
- creates an annotated git tag
- pushes the tag to `origin`
- creates a GitHub release with `gh release create`

Manual equivalent:

```bash
git tag -a v0.1.0 -m "v0.1.0"
git push origin v0.1.0
gh release create v0.1.0 --title "v0.1.0" --notes "Initial release"
```

## License

MIT. See [LICENSE](LICENSE).

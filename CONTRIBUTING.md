# Contributing

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

## Add A Skill

1. Add the skill folder under `.agents/skills/<name>/`.
2. Add `.agents/skills/<name>/SKILL.md` with YAML frontmatter containing `name` and `description`.
3. Keep bundled assets or helper scripts inside the skill folder.
4. Update the `Included Skills` list in `README.md`.
5. Run `./scripts/validate-skills.sh`.

## Test Installer Changes

Run the full installer smoke test:

```bash
./scripts/test-install.sh
```

The test installs into temporary git repos and checks default all-agent install,
`--codex`, `--amp`, `--pi`, `--claude`, second-run idempotency, managed block
replacement, and `--force`.

For shell changes, also run ShellCheck when it is installed:

```bash
shellcheck scripts/*.sh
```

## Update `templates/AGENTS.md`

Update `templates/AGENTS.md` when the shared operating policy changes for Codex,
Amp, or Pi users, or when installed skills need a new invocation rule.

Keep the `<!-- agent-policy-kit:start -->` and
`<!-- agent-policy-kit:end -->` markers around the managed block. The installer
uses those markers to update only package-owned content inside existing target
files.

Update `templates/CLAUDE.md` when Claude Code needs a different bridge to the
shared policy.

## Vendor Upstream `opentasks`

The bundled `opentasks` skill is vendored from
`https://github.com/luisalima/opentasks-skill`.

To update it:

```bash
tmp="$(mktemp -d)"
git clone https://github.com/luisalima/opentasks-skill.git "$tmp/opentasks-skill"
git -C "$tmp/opentasks-skill" checkout <commit>
rm -rf .agents/skills/opentasks
mkdir -p .agents/skills/opentasks
cp -R "$tmp/opentasks-skill"/. .agents/skills/opentasks/
rm -rf .agents/skills/opentasks/.git
```

Then update `THIRD_PARTY.md` with the copied commit and license, and run:

```bash
./scripts/validate-skills.sh
./scripts/test-install.sh
```

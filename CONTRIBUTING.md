# Contributing

## Publish A Release

Checklist:

- Run `./scripts/validate-skills.sh`, `./scripts/validate-version.sh`, `./scripts/test-install.sh`, `./scripts/test-hooks.sh`, and `shellcheck scripts/*.sh`.
- Confirm the README release install command is pinned to the tag being released.
- Tag and publish the release.
- Test install from the released tag with `./scripts/test-release-install.sh <tag>`.

Commit and push changes first, then run:

```bash
./scripts/release.sh "$(cat VERSION)" --notes "Initial release"
```

The release script:

- requires a clean working tree
- runs skill metadata validation, release-version validation, installer smoke tests, and ShellCheck
- creates an annotated git tag
- pushes the tag to `origin`
- creates a GitHub release with `gh release create`

Manual equivalent:

```bash
version="$(cat VERSION)"
git tag -a "$version" -m "$version"
git push origin "$version"
gh release create "$version" --title "$version" --notes "Initial release"
```

## Add A Skill

1. Add the skill folder under `.agents/skills/<name>/`.
2. Add `.agents/skills/<name>/SKILL.md` with YAML frontmatter containing `name` and `description`.
3. Keep bundled assets or helper scripts inside the skill folder.
4. Treat bundled `SKILL.md` files as package-managed. Target repos should put local skill extensions in `<installed-skill>/USER.md`, which the installer preserves during refresh.
5. Update the `Included Skills` list in `README.md`.
6. Run `./scripts/validate-skills.sh`.

## Test Installer Changes

Run the full installer smoke test:

```bash
./scripts/test-install.sh
```

The test installs into temporary git repos and checks default all-agent install,
`--codex`, `--amp`, `--pi`, `--claude`, second-run idempotency, managed block
replacement, skill refresh on update, and legacy `--force` compatibility.

For shell changes, also run ShellCheck when it is installed:

```bash
shellcheck scripts/*.sh
```

## Test Hook Changes

The opt-in enforcement hooks and their installer wiring have their own test
suite:

```bash
./scripts/test-hooks.sh
```

It `py_compile`s the hook scripts and the merge helper, and asserts that
`check_git_push.py` blocks force-pushes, `check_secret_edit.py` blocks
high-confidence secrets, and both allow benign or unparseable input. The
`--with-hooks` installer wiring (config merge, idempotency, malformed-config
abort) is covered by `./scripts/test-install.sh`.

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
./scripts/diff-opentasks-upstream.sh
```

The upstream comparison is networked, so GitHub Actions runs it in the
scheduled/manual `opentasks provenance` workflow rather than on every pull
request. A failure means `.agents/skills/opentasks` differs from the commit
recorded in `THIRD_PARTY.md`; either refresh the vendored copy from that commit
or update `THIRD_PARTY.md` to the new copied commit after reviewing the change.

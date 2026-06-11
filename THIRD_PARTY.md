# Third Party Code

## `opentasks` Skill

- Upstream: `https://github.com/luisalima/opentasks-skill`
- Copied commit: `e34d18b8d554a706105d8bd6403e952dc580f50a`
- License: MIT, preserved in `.agents/skills/opentasks/LICENSE`

Update process:

```bash
tmp="$(mktemp -d)"
git clone https://github.com/luisalima/opentasks-skill.git "$tmp/opentasks-skill"
git -C "$tmp/opentasks-skill" checkout <commit>
rm -rf .agents/skills/opentasks
mkdir -p .agents/skills/opentasks
cp -R "$tmp/opentasks-skill"/. .agents/skills/opentasks/
rm -rf .agents/skills/opentasks/.git
```

After updating, replace the copied commit above, confirm the upstream license,
run the installer and skill validation tests, and compare the vendored copy:

```bash
./scripts/diff-opentasks-upstream.sh
```

# Third Party Code

## `opentasks` Skill

- Upstream: `https://github.com/luisalima/opentasks-skill`
- Copied commit: `e34d18b`
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
and run the installer and skill validation tests.

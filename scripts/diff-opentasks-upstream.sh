#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
vendor_dir="$package_root/.agents/skills/opentasks"
upstream_url="https://github.com/luisalima/opentasks-skill.git"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

commit="$(
  awk -F': ' '/^- Copied commit:/ { print $2 }' "$package_root/THIRD_PARTY.md" | tr -d '`'
)"

[ -n "$commit" ] || fail "could not read copied commit from THIRD_PARTY.md"

case "$commit" in
  [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])
    ;;
  *)
    fail "copied commit must be a full 40-character SHA"
    ;;
esac

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

git clone --quiet "$upstream_url" "$tmp_root/opentasks-skill"
git -C "$tmp_root/opentasks-skill" checkout --quiet "$commit"
rm -rf "$tmp_root/opentasks-skill/.git"

diff -ru "$tmp_root/opentasks-skill" "$vendor_dir"

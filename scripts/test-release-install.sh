#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
version="${1:-$(sed -n '1p' "$package_root/VERSION")}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

extract_documented_one_liner() {
  awk '
    /One-liner clone \+ install into the current repo from the latest release:/ {
      want_block = 1
      next
    }
    want_block && $0 == "```bash" {
      in_block = 1
      next
    }
    in_block && $0 == "```" {
      exit
    }
    in_block {
      print
    }
  ' "$package_root/README.md"
}

one_liner="$(extract_documented_one_liner)"

[ -n "$one_liner" ] || fail "could not find documented release install one-liner in README.md"

case "$one_liner" in
  *"git clone --depth 1 --branch $version https://github.com/luisalima/agent-policy-kit.git"*)
    ;;
  *)
    fail "README.md release one-liner is not pinned to $version"
    ;;
esac

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

target="$tmp_root/target"
mkdir -p "$target"
git -C "$target" init --quiet

(
  cd "$target"
  eval "$one_liner"
)

[ -f "$target/AGENTS.md" ] || fail "missing AGENTS.md after documented install"
[ -f "$target/CLAUDE.md" ] || fail "missing CLAUDE.md after documented install"
[ -d "$target/.agents/skills/opentasks" ] || fail "missing .agents opentasks skill"
[ -d "$target/.claude/skills/opentasks" ] || fail "missing .claude opentasks skill"
grep -qF "<!-- agent-policy-kit:start -->" "$target/AGENTS.md" || fail "missing managed block in AGENTS.md"
grep -qF "<!-- agent-policy-kit:start -->" "$target/CLAUDE.md" || fail "missing managed block in CLAUDE.md"

echo "documented release install passed for $version"

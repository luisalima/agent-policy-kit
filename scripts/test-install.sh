#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

assert_dir() {
  [ -d "$1" ] || fail "missing directory: $1"
}

assert_no_path() {
  [ ! -e "$1" ] || fail "unexpected path exists: $1"
}

assert_contains() {
  local file="$1"
  local text="$2"
  grep -qF "$text" "$file" || fail "missing '$text' in $file"
}

assert_count() {
  local expected="$1"
  local text="$2"
  local file="$3"
  local actual

  actual="$(grep -cF "$text" "$file" || true)"
  [ "$actual" = "$expected" ] || fail "expected $expected occurrences of '$text' in $file, found $actual"
}

make_repo() {
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init --quiet
}

run_install() {
  local target="$1"
  shift
  "$package_root/scripts/install.sh" --target "$target" "$@" >/dev/null
}

assert_shared_layout() {
  local repo="$1"
  assert_file "$repo/AGENTS.md"
  assert_dir "$repo/.agents/skills/opentasks"
  assert_contains "$repo/AGENTS.md" "<!-- agent-policy-kit:start -->"
  assert_contains "$repo/AGENTS.md" "<!-- agent-policy-kit:end -->"
}

assert_claude_layout() {
  local repo="$1"
  assert_file "$repo/CLAUDE.md"
  assert_dir "$repo/.claude/skills/opentasks"
  assert_contains "$repo/CLAUDE.md" "<!-- agent-policy-kit:start -->"
  assert_contains "$repo/CLAUDE.md" "<!-- agent-policy-kit:end -->"
}

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

repo="$tmp_root/default"
make_repo "$repo"
run_install "$repo"
assert_shared_layout "$repo"
assert_claude_layout "$repo"

repo="$tmp_root/codex"
make_repo "$repo"
run_install "$repo" --codex
assert_shared_layout "$repo"
assert_no_path "$repo/CLAUDE.md"
assert_no_path "$repo/.claude"

repo="$tmp_root/amp"
make_repo "$repo"
run_install "$repo" --amp
assert_shared_layout "$repo"
assert_no_path "$repo/CLAUDE.md"
assert_no_path "$repo/.claude"

repo="$tmp_root/pi"
make_repo "$repo"
run_install "$repo" --pi
assert_shared_layout "$repo"
assert_no_path "$repo/CLAUDE.md"
assert_no_path "$repo/.claude"

repo="$tmp_root/claude"
make_repo "$repo"
run_install "$repo" --claude
assert_claude_layout "$repo"
assert_no_path "$repo/AGENTS.md"
assert_no_path "$repo/.agents"

repo="$tmp_root/idempotent"
make_repo "$repo"
run_install "$repo"
run_install "$repo"
assert_count 1 "<!-- agent-policy-kit:start -->" "$repo/AGENTS.md"
assert_count 1 "<!-- agent-policy-kit:end -->" "$repo/AGENTS.md"
assert_count 1 "<!-- agent-policy-kit:start -->" "$repo/CLAUDE.md"
assert_count 1 "<!-- agent-policy-kit:end -->" "$repo/CLAUDE.md"

repo="$tmp_root/force"
make_repo "$repo"
run_install "$repo"
printf 'stale\n' > "$repo/.agents/skills/opentasks/STALE"
printf 'stale\n' > "$repo/.claude/skills/opentasks/STALE"
run_install "$repo" --force
assert_no_path "$repo/.agents/skills/opentasks/STALE"
assert_no_path "$repo/.claude/skills/opentasks/STALE"
assert_shared_layout "$repo"
assert_claude_layout "$repo"

repo="$tmp_root/replace-block"
make_repo "$repo"
cat > "$repo/AGENTS.md" <<'EOF'
# Existing Project

keep this line

<!-- agent-policy-kit:start -->
old managed content
<!-- agent-policy-kit:end -->

keep this too
EOF
run_install "$repo" --codex
assert_contains "$repo/AGENTS.md" "keep this line"
assert_contains "$repo/AGENTS.md" "keep this too"
assert_contains "$repo/AGENTS.md" "## Agent rules"
if grep -qF "old managed content" "$repo/AGENTS.md"; then
  fail "managed block was not replaced"
fi

echo "install smoke tests passed"

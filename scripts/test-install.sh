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

assert_no_match() {
  local root="$1"
  local pattern="$2"
  local match

  match="$(find "$root" -name "$pattern" -print -quit)"
  [ -z "$match" ] || fail "unexpected path matching $pattern: $match"
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

assert_install_fails() {
  local target="$1"
  shift
  if "$package_root/scripts/install.sh" --target "$target" "$@" >/dev/null 2>&1; then
    fail "expected installer to fail for $target"
  fi
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

run_install_with_path() {
  local path_prefix="$1"
  local target="$2"
  shift 2
  PATH="$path_prefix:$PATH" "$package_root/scripts/install.sh" --target "$target" "$@" >/dev/null
}

assert_install_fails_with_path() {
  local path_prefix="$1"
  local target="$2"
  shift 2
  if PATH="$path_prefix:$PATH" "$package_root/scripts/install.sh" --target "$target" "$@" >/dev/null 2>&1; then
    fail "expected installer to fail for $target"
  fi
}

assert_shared_layout() {
  local repo="$1"
  assert_file "$repo/AGENTS.md"
  assert_dir "$repo/.agents/skills/opentasks"
  assert_contains "$repo/AGENTS.md" "<!-- agent-policy-kit:start -->"
  assert_contains "$repo/AGENTS.md" "<!-- agent-policy-kit:end -->"
  assert_contains "$repo/AGENTS.md" "also read \`USER.md\` in the same skill directory"
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
printf 'stale\n' > "$repo/.agents/skills/opentasks/STALE"
printf 'stale\n' > "$repo/.claude/skills/opentasks/STALE"
printf 'local shared extension\n' > "$repo/.agents/skills/opentasks/USER.md"
printf 'local claude extension\n' > "$repo/.claude/skills/opentasks/USER.md"
run_install "$repo"
assert_count 1 "<!-- agent-policy-kit:start -->" "$repo/AGENTS.md"
assert_count 1 "<!-- agent-policy-kit:end -->" "$repo/AGENTS.md"
assert_count 1 "<!-- agent-policy-kit:start -->" "$repo/CLAUDE.md"
assert_count 1 "<!-- agent-policy-kit:end -->" "$repo/CLAUDE.md"
assert_no_path "$repo/.agents/skills/opentasks/STALE"
assert_no_path "$repo/.claude/skills/opentasks/STALE"
assert_contains "$repo/.agents/skills/opentasks/USER.md" "local shared extension"
assert_contains "$repo/.claude/skills/opentasks/USER.md" "local claude extension"

repo="$tmp_root/atomic-refresh"
make_repo "$repo"
run_install "$repo" --codex
printf 'previous install content\n' > "$repo/.agents/skills/opentasks/PREVIOUS"
cp_wrapper_dir="$tmp_root/failing-cp-bin"
mkdir -p "$cp_wrapper_dir"
cat > "$cp_wrapper_dir/cp" <<'EOF'
#!/usr/bin/env bash
for arg in "$@"; do
  if [ "${AGENT_POLICY_KIT_FAIL_CP_OPENTASKS:-0}" = "1" ] && [ "${arg##*/}" = "opentasks" ]; then
    echo "simulated cp failure for opentasks" >&2
    exit 1
  fi
done
if [ "${AGENT_POLICY_KIT_FAIL_CP:-0}" = "1" ]; then
  echo "simulated cp failure" >&2
  exit 1
fi
exec /bin/cp "$@"
EOF
chmod +x "$cp_wrapper_dir/cp"
AGENT_POLICY_KIT_FAIL_CP_OPENTASKS=1 assert_install_fails_with_path "$cp_wrapper_dir" "$repo" --codex
assert_contains "$repo/.agents/skills/opentasks/PREVIOUS" "previous install content"
assert_no_match "$repo/.agents/skills" ".opentasks.staging.*"
assert_no_match "$repo/.agents/skills" ".opentasks.backup.*"

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

repo="$tmp_root/malformed-block"
make_repo "$repo"
cat > "$repo/AGENTS.md" <<'EOF'
# Existing Project

keep this line

<!-- agent-policy-kit:start -->
old managed content
EOF
cat > "$repo/CLAUDE.md" <<'EOF'
# Existing Claude Notes

keep claude line
EOF
before_agents="$(mktemp)"
before_claude="$(mktemp)"
cp "$repo/AGENTS.md" "$before_agents"
cp "$repo/CLAUDE.md" "$before_claude"
assert_install_fails "$repo"
cmp -s "$repo/AGENTS.md" "$before_agents" || fail "malformed AGENTS.md was rewritten"
cmp -s "$repo/CLAUDE.md" "$before_claude" || fail "CLAUDE.md was rewritten after preflight failure"
assert_no_path "$repo/.agents"
assert_no_path "$repo/.claude"

repo="$tmp_root/duplicate-managed-block"
make_repo "$repo"
run_install "$repo"
cat > "$repo/AGENTS.md" <<'EOF'
# Existing Project

<!-- agent-policy-kit:start -->
first managed content
<!-- agent-policy-kit:end -->

<!-- agent-policy-kit:start -->
second managed content
<!-- agent-policy-kit:end -->
EOF
printf 'keep installed skill\n' > "$repo/.agents/skills/opentasks/PRESERVE"
before_agents="$(mktemp)"
before_claude="$(mktemp)"
cp "$repo/AGENTS.md" "$before_agents"
cp "$repo/CLAUDE.md" "$before_claude"
assert_install_fails "$repo"
cmp -s "$repo/AGENTS.md" "$before_agents" || fail "duplicate-block AGENTS.md was rewritten"
cmp -s "$repo/CLAUDE.md" "$before_claude" || fail "CLAUDE.md was rewritten after duplicate-block preflight failure"
assert_contains "$repo/.agents/skills/opentasks/PRESERVE" "keep installed skill"

repo="$tmp_root/reversed-managed-block"
make_repo "$repo"
run_install "$repo"
cat > "$repo/AGENTS.md" <<'EOF'
# Existing Project

<!-- agent-policy-kit:end -->
old managed content
<!-- agent-policy-kit:start -->
EOF
printf 'keep installed skill\n' > "$repo/.agents/skills/opentasks/PRESERVE"
before_agents="$(mktemp)"
before_claude="$(mktemp)"
cp "$repo/AGENTS.md" "$before_agents"
cp "$repo/CLAUDE.md" "$before_claude"
assert_install_fails "$repo"
cmp -s "$repo/AGENTS.md" "$before_agents" || fail "reversed-block AGENTS.md was rewritten"
cmp -s "$repo/CLAUDE.md" "$before_claude" || fail "CLAUDE.md was rewritten after reversed-block preflight failure"
assert_contains "$repo/.agents/skills/opentasks/PRESERVE" "keep installed skill"

echo "install smoke tests passed"

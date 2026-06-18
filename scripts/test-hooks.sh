#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
hooks_dir="$package_root/scripts/hooks"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

# Run a hook with JSON on stdin and assert the exit code.
assert_exit() {
  local expected="$1"
  local hook="$2"
  local input="$3"
  local label="$4"
  local rc=0

  printf '%s' "$input" | python3 "$hooks_dir/$hook" >/dev/null 2>&1 || rc=$?
  [ "$rc" = "$expected" ] || fail "$label: expected exit $expected, got $rc"
}

# Every Python file must at least compile.
python3 -m py_compile \
  "$hooks_dir/check_git_push.py" \
  "$hooks_dir/check_secret_edit.py" \
  "$package_root/scripts/merge_hook_config.py" \
  || fail "py_compile failed"

# --- check_git_push.py ---------------------------------------------------

assert_exit 2 check_git_push.py \
  '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' \
  "force push (--force) is blocked"

assert_exit 2 check_git_push.py \
  '{"tool_name":"Bash","tool_input":{"command":"git push -f origin main"}}' \
  "force push (-f) is blocked"

assert_exit 2 check_git_push.py \
  '{"tool_name":"Bash","tool_input":{"command":"git push --force-with-lease origin main"}}' \
  "force push (--force-with-lease) is blocked"

assert_exit 0 check_git_push.py \
  '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' \
  "normal push is allowed"

assert_exit 0 check_git_push.py \
  '{"tool_name":"Bash","tool_input":{"command":"ls -f"}}' \
  "non-push command with -f is allowed"

assert_exit 0 check_git_push.py \
  'not json at all' \
  "unparseable stdin fails open"

# --- check_secret_edit.py ------------------------------------------------

assert_exit 2 check_secret_edit.py \
  '{"tool_name":"Write","tool_input":{"file_path":"id_rsa","content":"-----BEGIN OPENSSH PRIVATE KEY-----\nabc\n-----END OPENSSH PRIVATE KEY-----"}}' \
  "private key content is blocked"

assert_exit 2 check_secret_edit.py \
  '{"tool_name":"Write","tool_input":{"file_path":"config.py","content":"aws_key = \"AKIAIOSFODNN7REALKEY\""}}' \
  "AWS access key id is blocked"

assert_exit 2 check_secret_edit.py \
  '{"tool_name":"Edit","tool_input":{"file_path":"app.py","new_string":"api_key = \"sk_live_abcd1234efgh5678ijkl\""}}' \
  "real-looking secret assignment is blocked"

assert_exit 0 check_secret_edit.py \
  '{"tool_name":"Write","tool_input":{"file_path":"README.md","content":"export AWS_KEY=AKIAIOSFODNN7EXAMPLE"}}' \
  "documented AWS EXAMPLE key is allowed"

assert_exit 0 check_secret_edit.py \
  '{"tool_name":"Edit","tool_input":{"file_path":"config.py","new_string":"password = \"<your-password>\""}}' \
  "placeholder password is allowed"

assert_exit 0 check_secret_edit.py \
  '{"tool_name":"Write","tool_input":{"file_path":"app.py","content":"def add(a, b):\n    return a + b"}}' \
  "clean content is allowed"

assert_exit 0 check_secret_edit.py \
  'not json at all' \
  "unparseable stdin fails open"

echo "hook tests passed"

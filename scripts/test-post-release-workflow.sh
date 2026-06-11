#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
workflow="$package_root/.github/workflows/post-release-install.yml"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

assert_contains() {
  local text="$1"
  grep -qF "$text" "$workflow" || fail "missing '$text' in $workflow"
}

assert_contains "release:"
assert_contains "types: [published]"
assert_contains "workflow_dispatch:"
assert_contains "github.event.release.tag_name || inputs.version"
assert_contains "./scripts/test-release-install.sh \"\$RELEASE_VERSION\""

echo "post-release workflow tests passed"

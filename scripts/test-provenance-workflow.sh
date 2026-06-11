#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
workflow="$package_root/.github/workflows/opentasks-provenance.yml"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

[ -f "$workflow" ] || fail "missing $workflow"

assert_contains() {
  local text="$1"
  grep -qF "$text" "$workflow" || fail "missing '$text' in $workflow"
}

assert_contains "workflow_dispatch:"
assert_contains "schedule:"
assert_contains "cron:"
assert_contains "./scripts/diff-opentasks-upstream.sh"

echo "provenance workflow tests passed"

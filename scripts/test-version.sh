#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
validator="$package_root/scripts/validate-version.sh"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

make_fixture() {
  local root="$1"
  local version="$2"

  mkdir -p "$root/.github/workflows"
  printf '%s\n' "$version" > "$root/VERSION"
  cat > "$root/README.md" <<EOF
# fixture

One-liner clone + install into the current repo from the latest release:

\`\`\`bash
tmp="\$(mktemp -d)" && git clone --depth 1 --branch $version https://github.com/luisalima/agent-policy-kit.git "\$tmp/agent-policy-kit" && "\$tmp/agent-policy-kit/scripts/install.sh" --target .
\`\`\`
EOF
  cat > "$root/CHANGELOG.md" <<EOF
# Changelog

## $version

- Fixture release.
EOF
  cat > "$root/.github/workflows/post-release-install.yml" <<EOF
name: Post-release install

on:
  workflow_dispatch:
    inputs:
      version:
        default: $version
EOF
}

assert_validator_fails() {
  local root="$1"
  if "$validator" "$root" >/dev/null 2>&1; then
    fail "expected version validation to fail for $root"
  fi
}

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

fixture="$tmp_root/aligned"
make_fixture "$fixture" "v0.1.0"
"$validator" "$fixture" >/dev/null

fixture="$tmp_root/readme-drift"
make_fixture "$fixture" "v0.1.0"
perl -0pi -e 's/--branch v0\.1\.0/--branch v9.9.9/' "$fixture/README.md"
assert_validator_fails "$fixture"

fixture="$tmp_root/changelog-drift"
make_fixture "$fixture" "v0.1.0"
perl -0pi -e 's/## v0\.1\.0/## v9.9.9/' "$fixture/CHANGELOG.md"
assert_validator_fails "$fixture"

fixture="$tmp_root/workflow-drift"
make_fixture "$fixture" "v0.1.0"
perl -0pi -e 's/default: v0\.1\.0/default: v9.9.9/' "$fixture/.github/workflows/post-release-install.yml"
assert_validator_fails "$fixture"

if "$package_root/scripts/release.sh" v999.999.999 >/dev/null 2>&1; then
  fail "expected release script to reject a tag that does not match VERSION"
fi

echo "version validation tests passed"

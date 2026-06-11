#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

version_file="$root/VERSION"
readme="$root/README.md"
changelog="$root/CHANGELOG.md"
post_release_workflow="$root/.github/workflows/post-release-install.yml"

[ -f "$version_file" ] || fail "missing VERSION"
[ -f "$readme" ] || fail "missing README.md"
[ -f "$changelog" ] || fail "missing CHANGELOG.md"
[ -f "$post_release_workflow" ] || fail "missing .github/workflows/post-release-install.yml"

version="$(sed -n '1p' "$version_file")"
[ -n "$version" ] || fail "VERSION is empty"

if ! printf '%s\n' "$version" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  fail "VERSION must be a v-prefixed semantic version, found: $version"
fi

if ! grep -qF "git clone --depth 1 --branch $version https://github.com/luisalima/agent-policy-kit.git" "$readme"; then
  fail "README.md release install command is not pinned to $version"
fi

if ! grep -qF "## $version" "$changelog"; then
  fail "CHANGELOG.md is missing heading ## $version"
fi

if ! grep -qF "default: $version" "$post_release_workflow"; then
  fail ".github/workflows/post-release-install.yml default version is not $version"
fi

echo "release version references match $version"

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

fixture="$tmp_root/release-fixture"
mkdir -p "$fixture"
cp -R \
  "$package_root/.agents" \
  "$package_root/.github" \
  "$package_root/scripts" \
  "$package_root/templates" \
  "$package_root/README.md" \
  "$package_root/CHANGELOG.md" \
  "$package_root/CONTRIBUTING.md" \
  "$package_root/VERSION" \
  "$fixture/"

git -C "$fixture" init --quiet
git -C "$fixture" config user.email "test@example.com"
git -C "$fixture" config user.name "Release Test"

perl -0pi -e 's/## v0\.1\.0/## v9.9.9/' "$fixture/CHANGELOG.md"

git -C "$fixture" add .
git -C "$fixture" commit --quiet -m "fixture"

fake_bin="$tmp_root/bin"
mkdir -p "$fake_bin"
cat > "$fake_bin/gh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$fake_bin/gh"

version="$(sed -n '1p' "$fixture/VERSION")"
if (cd "$fixture" && PATH="$fake_bin:$PATH" scripts/release.sh "$version" --notes "fixture") >/dev/null 2>&1; then
  fail "expected release script to fail when readiness gates fail"
fi

if git -C "$fixture" rev-parse "$version" >/dev/null 2>&1; then
  fail "release script created tag before readiness gates passed"
fi

echo "release script tests passed"

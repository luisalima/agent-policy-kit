#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/release.sh VERSION [--notes NOTES]

Creates and publishes a GitHub release for the current commit.

Examples:
  scripts/release.sh "$(cat VERSION)"
  scripts/release.sh 0.1.0 --notes "Initial release"

Requires:
  - clean git working tree
  - authenticated gh CLI
  - origin remote pointing at GitHub
EOF
}

run_gate() {
  local label="$1"
  shift

  echo "Running $label..."
  if ! "$@"; then
    echo "ERROR: readiness gate failed: $label" >&2
    exit 1
  fi
}

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
expected_version="$(sed -n '1p' "$package_root/VERSION")"

case "$1" in
  -h|--help)
    usage
    exit 0
    ;;
esac

version="$1"
shift

case "$version" in
  v*) tag="$version" ;;
  *) tag="v$version" ;;
esac

if [ "$tag" != "$expected_version" ]; then
  echo "ERROR: release tag $tag does not match VERSION ($expected_version)" >&2
  exit 1
fi

notes=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --notes)
      if [ "$#" -lt 2 ]; then
        echo "ERROR: --notes requires text" >&2
        exit 2
      fi
      notes="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -n "$(git status --porcelain)" ]; then
  echo "ERROR: working tree is not clean. Commit changes before releasing." >&2
  exit 1
fi

if git rev-parse "$tag" >/dev/null 2>&1; then
  echo "ERROR: tag already exists: $tag" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI is required to create the GitHub release." >&2
  exit 1
fi

run_gate "skill metadata validation" "$package_root/scripts/validate-skills.sh"
run_gate "release version validation" "$package_root/scripts/validate-version.sh" "$package_root"
run_gate "release version validation tests" "$package_root/scripts/test-version.sh"
run_gate "installer smoke tests" "$package_root/scripts/test-install.sh"
run_gate "hook tests" "$package_root/scripts/test-hooks.sh"
run_gate "ShellCheck" shellcheck "$package_root"/scripts/*.sh

if [ -z "$notes" ]; then
  notes="Release $tag"
fi

git tag -a "$tag" -m "$tag"
git push origin "$tag"
gh release create "$tag" --title "$tag" --notes "$notes"

echo "Published $tag"

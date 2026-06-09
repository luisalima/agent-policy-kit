#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
skills_root="$package_root/.agents/skills"

for skill_dir in "$skills_root"/*; do
  [ -d "$skill_dir" ] || continue

  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || {
    echo "ERROR: missing $skill_file" >&2
    exit 1
  }

  awk '
    BEGIN { in_frontmatter = 0 }
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && /^name:[[:space:]]*[^[:space:]]/ { has_name = 1 }
    in_frontmatter && /^description:[[:space:]]*.+/ { has_description = 1 }
    END {
      if (!has_name || !has_description) {
        exit 1
      }
    }
  ' "$skill_file" || {
    echo "ERROR: $skill_file must have name and description frontmatter" >&2
    exit 1
  }
done

echo "skill metadata valid"

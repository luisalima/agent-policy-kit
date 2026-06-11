#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [--target PATH] [--codex | --amp | --pi | --claude] [--force]

Installs the repo-local agent operating policy into a target repository.

Options:
  --target PATH   Repository to install into. Defaults to current directory.
  --codex         Install Codex support: AGENTS.md + .agents/skills.
  --amp           Install Amp support: AGENTS.md + .agents/skills.
  --pi            Install Pi support: AGENTS.md + .agents/skills.
  --claude        Install Claude support: CLAUDE.md + .claude/skills.
  --codex-only    Legacy alias for --codex.
  --claude-only   Legacy alias for --claude.
  --force         Legacy compatibility flag. Skill folders are always refreshed.
  -h, --help      Show this help.

The installer appends or updates only the managed agent-policy-kit block and
does not overwrite user-authored content in existing AGENTS.md or CLAUDE.md
files.

If no agent flags are provided, installs all supported layouts.
EOF
}

target="."
agent_flag_seen=0
install_shared=0
install_claude=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      if [ "$#" -lt 2 ]; then
        echo "ERROR: --target requires a path" >&2
        exit 2
      fi
      target="$2"
      shift 2
      ;;
    --codex|--amp|--pi)
      agent_flag_seen=1
      install_shared=1
      shift
      ;;
    --claude)
      agent_flag_seen=1
      install_claude=1
      shift
      ;;
    --codex-only)
      agent_flag_seen=1
      install_shared=1
      install_claude=0
      shift
      ;;
    --claude-only)
      agent_flag_seen=1
      install_shared=0
      install_claude=1
      shift
      ;;
    --force)
      shift
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

if [ "$agent_flag_seen" -eq 0 ]; then
  install_shared=1
  install_claude=1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_root="$(cd "$script_dir/.." && pwd)"
target_root="$(cd "$target" && pwd)"

validate_managed_block() {
  local destination="$1"
  local start_marker="<!-- agent-policy-kit:start -->"
  local end_marker="<!-- agent-policy-kit:end -->"

  [ -f "$destination" ] || return 0

  if ! awk \
    -v start_marker="$start_marker" \
    -v end_marker="$end_marker" '
      $0 == start_marker {
        starts++
        if (in_block || ends > 0) {
          bad = 1
        }
        in_block = 1
        next
      }
      $0 == end_marker {
        ends++
        if (!in_block) {
          bad = 1
        }
        in_block = 0
        next
      }
      END {
        if (starts == 0 && ends == 0) {
          exit 0
        }
        if (starts == 1 && ends == 1 && !bad && !in_block) {
          exit 0
        }
        exit 1
      }
    ' "$destination"; then
    echo "ERROR: ${destination#"$target_root"/} has malformed agent-policy-kit markers" >&2
    exit 1
  fi
}

append_or_create() {
  local destination="$1"
  local template="$2"
  local legacy_marker="$3"
  local start_marker="<!-- agent-policy-kit:start -->"
  local end_marker="<!-- agent-policy-kit:end -->"
  local temp_file

  if [ ! -f "$destination" ]; then
    mkdir -p "$(dirname "$destination")"
    cp "$template" "$destination"
    echo "created ${destination#"$target_root"/}"
    return
  fi

  if grep -qF "$start_marker" "$destination"; then
    if ! grep -qF "$end_marker" "$destination"; then
      echo "ERROR: ${destination#"$target_root"/} has ${start_marker} without ${end_marker}" >&2
      exit 1
    fi

    temp_file="$(mktemp)"
    awk \
      -v start_marker="$start_marker" \
      -v end_marker="$end_marker" \
      -v template="$template" '
        $0 == start_marker {
          while ((getline line < template) > 0) {
            print line
          }
          close(template)
          in_block = 1
          next
        }
        $0 == end_marker && in_block {
          in_block = 0
          next
        }
        !in_block {
          print
        }
      ' "$destination" > "$temp_file"
    mv "$temp_file" "$destination"
    echo "updated ${destination#"$target_root"/} (replaced managed block)"
    return
  fi

  if grep -qF "$legacy_marker" "$destination"; then
    echo "kept ${destination#"$target_root"/} (legacy section already present)"
    return
  fi

  {
    printf '\n\n'
    cat "$template"
  } >> "$destination"
  echo "updated ${destination#"$target_root"/} (appended missing section)"
}

copy_skill_dir() {
  local source_dir="$1"
  local destination_dir="$2"
  local destination_parent
  local destination_name
  local staging_parent
  local staged_dir
  local backup_parent=""
  local backup_dir=""

  destination_parent="$(dirname "$destination_dir")"
  destination_name="$(basename "$destination_dir")"

  mkdir -p "$destination_parent"
  staging_parent="$(mktemp -d "$destination_parent/.${destination_name}.staging.XXXXXX")"
  staged_dir="$staging_parent/$destination_name"

  if ! cp -R "$source_dir" "$staged_dir"; then
    rm -rf "$staging_parent"
    return 1
  fi

  if [ -f "$destination_dir/USER.md" ]; then
    if ! cp "$destination_dir/USER.md" "$staged_dir/USER.md"; then
      rm -rf "$staging_parent"
      return 1
    fi
  fi

  if [ -d "$destination_dir" ]; then
    backup_parent="$(mktemp -d "$destination_parent/.${destination_name}.backup.XXXXXX")"
    backup_dir="$backup_parent/$destination_name"

    if ! mv "$destination_dir" "$backup_dir"; then
      rm -rf "$staging_parent" "$backup_parent"
      return 1
    fi

    if ! mv "$staged_dir" "$destination_dir"; then
      mv "$backup_dir" "$destination_dir"
      rm -rf "$staging_parent" "$backup_parent"
      return 1
    fi

    rm -rf "$staging_parent" "$backup_parent"
    echo "updated ${destination_dir#"$target_root"/}"
    return
  fi

  if ! mv "$staged_dir" "$destination_dir"; then
    rm -rf "$staging_parent"
    return 1
  fi

  rm -rf "$staging_parent"
  echo "installed ${destination_dir#"$target_root"/}"
}

copy_all_skills() {
  local source_root="$1"
  local destination_root="$2"
  local skill_dir

  for skill_dir in "$source_root"/*; do
    if [ -d "$skill_dir" ]; then
      copy_skill_dir "$skill_dir" "$destination_root/$(basename "$skill_dir")"
    fi
  done
}

if [ "$install_shared" -eq 1 ]; then
  validate_managed_block "$target_root/AGENTS.md"
fi

if [ "$install_claude" -eq 1 ]; then
  validate_managed_block "$target_root/CLAUDE.md"
fi

if [ "$install_shared" -eq 1 ]; then
  append_or_create "$target_root/AGENTS.md" "$package_root/templates/AGENTS.md" "## Agent rules"
  copy_all_skills "$package_root/.agents/skills" "$target_root/.agents/skills"
fi

if [ "$install_claude" -eq 1 ]; then
  append_or_create "$target_root/CLAUDE.md" "$package_root/templates/CLAUDE.md" "## Shared Agent Policy"
  copy_all_skills "$package_root/.agents/skills" "$target_root/.claude/skills"
fi

echo
echo "Installed agent operating policy into $target_root"
echo "Next: run /opentasks bootstrap in the target repo if you want docs/tasks/ tracking."

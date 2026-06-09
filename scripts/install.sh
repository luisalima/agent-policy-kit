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
  --force         Replace existing installed skill folders.
  -h, --help      Show this help.

The installer appends missing instruction sections but does not overwrite an
existing AGENTS.md or CLAUDE.md file.

If no agent flags are provided, installs all supported layouts.
EOF
}

target="."
agent_flag_seen=0
install_shared=0
install_claude=0
force=0

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
      force=1
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

append_or_create() {
  local destination="$1"
  local template="$2"
  local marker="$3"

  if [ ! -f "$destination" ]; then
    mkdir -p "$(dirname "$destination")"
    cp "$template" "$destination"
    echo "created ${destination#$target_root/}"
    return
  fi

  if grep -qF "$marker" "$destination"; then
    echo "kept ${destination#$target_root/} (section already present)"
    return
  fi

  {
    printf '\n\n'
    cat "$template"
  } >> "$destination"
  echo "updated ${destination#$target_root/} (appended missing section)"
}

copy_skill_dir() {
  local source_dir="$1"
  local destination_dir="$2"

  if [ -d "$destination_dir" ]; then
    if [ "$force" -eq 0 ]; then
      echo "kept ${destination_dir#$target_root/} (already exists; use --force to replace)"
      return
    fi
    rm -rf "$destination_dir"
  fi

  mkdir -p "$(dirname "$destination_dir")"
  cp -R "$source_dir" "$destination_dir"
  echo "installed ${destination_dir#$target_root/}"
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

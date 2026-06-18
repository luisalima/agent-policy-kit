#!/usr/bin/env python3
"""Idempotently merge agent-policy-kit hook entries into an agent config file.

Usage: merge_hook_config.py <config-file> <flavor>
  flavor: "claude" (.claude/settings.json) or "codex" (.codex/hooks.json)

Inserts PreToolUse entries that run the kit's hook scripts, preserving any
existing config and any unrelated PreToolUse entries. Re-running replaces only
the kit's own entries (identified by the hook script filenames), so installs
stay idempotent. A config file that exists but is not valid JSON aborts with a
non-zero exit rather than being overwritten.
"""
import json
import os
import sys

# Hook scripts the kit manages, identified by filename inside command strings.
SCRIPT_NAMES = ("check_git_push.py", "check_secret_edit.py")


def command_path(flavor, script):
    rel = "scripts/hooks/" + script
    if flavor == "claude":
        return 'python3 "$CLAUDE_PROJECT_DIR/{0}"'.format(rel)
    return 'python3 "$(git rev-parse --show-toplevel)/{0}"'.format(rel)


def desired_entries(flavor):
    push_matcher = "Bash"
    edit_matcher = "Write|Edit" if flavor == "claude" else "Edit|Write|apply_patch"

    def entry(matcher, script, status):
        inner = {"type": "command", "command": command_path(flavor, script)}
        if flavor == "codex":
            inner["statusMessage"] = status
        return {"matcher": matcher, "hooks": [inner]}

    return [
        entry(push_matcher, "check_git_push.py", "Checking push policy"),
        entry(edit_matcher, "check_secret_edit.py", "Checking edit for secrets"),
    ]


def references_kit_script(pre_tool_use_entry):
    for inner in pre_tool_use_entry.get("hooks", []):
        command = inner.get("command", "") if isinstance(inner, dict) else ""
        if any(name in command for name in SCRIPT_NAMES):
            return True
    return False


def load_config(path):
    if not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as handle:
        text = handle.read().strip()
    if not text:
        return {}
    try:
        data = json.loads(text)
    except ValueError as exc:
        sys.stderr.write(
            "ERROR: {0} exists but is not valid JSON ({1}); refusing to "
            "overwrite.\n".format(path, exc)
        )
        sys.exit(1)
    if not isinstance(data, dict):
        sys.stderr.write(
            "ERROR: {0} does not contain a JSON object; refusing to "
            "overwrite.\n".format(path)
        )
        sys.exit(1)
    return data


def main(argv):
    if len(argv) != 3:
        sys.stderr.write("usage: merge_hook_config.py <config-file> <flavor>\n")
        return 2
    path, flavor = argv[1], argv[2]
    if flavor not in ("claude", "codex"):
        sys.stderr.write("ERROR: flavor must be 'claude' or 'codex'\n")
        return 2

    config = load_config(path)
    hooks = config.get("hooks")
    if not isinstance(hooks, dict):
        hooks = {}
    pre = hooks.get("PreToolUse")
    if not isinstance(pre, list):
        pre = []

    # Drop our previously-installed entries, keep everything else, re-add fresh.
    preserved = [e for e in pre if not (isinstance(e, dict) and references_kit_script(e))]
    hooks["PreToolUse"] = preserved + desired_entries(flavor)
    config["hooks"] = hooks

    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(config, handle, indent=2)
        handle.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

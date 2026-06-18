#!/usr/bin/env python3
"""PreToolUse guard: block force-pushes.

Reads the hook payload as JSON on stdin, extracts the shell command, and blocks
(exit 2) when it is a `git push` carrying a force flag. Anything it cannot parse
or does not recognize is allowed (exit 0): this is a defense-in-depth guard on
the hot path, not an airtight gate. It backs the "no destructive or
history-rewriting operations without approval" rule.
"""
import json
import shlex
import sys

FORCE_FLAGS = {"-f", "--force", "--force-with-lease"}


def load_command():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return ""
    if not isinstance(data, dict):
        return ""
    tool_input = data.get("tool_input") or data.get("toolInput") or {}
    if isinstance(tool_input, dict):
        command = tool_input.get("command")
        if isinstance(command, str):
            return command
    command = data.get("command")
    return command if isinstance(command, str) else ""


def is_force_push(command):
    if "push" not in command:
        return False
    try:
        tokens = shlex.split(command)
    except ValueError:
        tokens = command.split()
    # Inspect each git-push invocation within the command line.
    for index, token in enumerate(tokens):
        if token != "git":
            continue
        rest = tokens[index + 1:]
        if "push" not in rest:
            continue
        for flag in rest:
            if flag in FORCE_FLAGS or flag.startswith("--force-with-lease="):
                return True
    return False


def main():
    command = load_command()
    if command and is_force_push(command):
        sys.stderr.write(
            "Blocked: force-push detected. Force-pushing rewrites remote "
            "history and is a destructive operation that requires explicit "
            "approval. Re-run without --force/--force-with-lease, or ask the "
            "user to confirm.\n"
        )
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())

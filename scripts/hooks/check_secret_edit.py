#!/usr/bin/env python3
"""PreToolUse guard: block writing high-confidence secrets into files.

Reads the hook payload as JSON on stdin, gathers the text being written (Write
content, Edit new_string, apply_patch body, etc.), and blocks (exit 2) when it
contains a high-confidence credential. Anything it cannot parse is allowed (exit
0): this is a defense-in-depth guard, deliberately biased toward structural,
low-false-positive patterns rather than broad heuristics. It backs the "never
write secrets or credentials into tracked files" rule.
"""
import json
import re
import sys

# High-confidence structural patterns. Each is (label, compiled regex).
PATTERNS = [
    ("private key block", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
    ("AWS access key id", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("GitHub personal access token", re.compile(r"\bghp_[A-Za-z0-9]{36}\b")),
    ("GitHub fine-grained token", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{22,}\b")),
    ("Slack token", re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b")),
    ("Google API key", re.compile(r"\bAIza[0-9A-Za-z_\-]{35}\b")),
    ("Stripe secret key", re.compile(r"\bsk_live_[0-9A-Za-z]{16,}\b")),
]

# Conservative generic-assignment pattern: a secret-ish name set to a quoted
# literal of reasonable length.
ASSIGNMENT = re.compile(
    r"(?i)(secret|password|passwd|api[_-]?key|access[_-]?key|auth[_-]?token|token)"
    r"\s*[:=]\s*['\"]([^'\"]{8,})['\"]"
)

# Substrings that mark a value as an obvious placeholder, not a real secret.
PLACEHOLDER_MARKERS = (
    "example",
    "your-",
    "your_",
    "changeme",
    "change-me",
    "placeholder",
    "redacted",
    "xxxx",
    "...",
    "<",
    "${",
    "{{",
    "os.environ",
    "getenv",
    "process.env",
)


def collect_strings(value, out):
    if isinstance(value, str):
        out.append(value)
    elif isinstance(value, dict):
        for item in value.values():
            collect_strings(item, out)
    elif isinstance(value, list):
        for item in value:
            collect_strings(item, out)


def load_text():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return None
    if not isinstance(data, dict):
        return None
    tool_input = data.get("tool_input") or data.get("toolInput") or {}
    parts = []
    collect_strings(tool_input, parts)
    return "\n".join(parts)


def looks_like_placeholder(value):
    lowered = value.lower()
    return any(marker in lowered for marker in PLACEHOLDER_MARKERS)


def find_secret(text):
    for label, pattern in PATTERNS:
        match = pattern.search(text)
        if not match:
            continue
        if looks_like_placeholder(match.group(0)):
            continue
        return label
    match = ASSIGNMENT.search(text)
    if match and not looks_like_placeholder(match.group(2)):
        return "hardcoded credential"
    return None


def main():
    text = load_text()
    if not text:
        return 0
    label = find_secret(text)
    if label:
        sys.stderr.write(
            "Blocked: this write appears to contain a {0}. Do not commit "
            "secrets to tracked files; use the environment or the repo's secret "
            "mechanism. If this is a false positive, ask the user to confirm.\n"
            .format(label)
        )
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())

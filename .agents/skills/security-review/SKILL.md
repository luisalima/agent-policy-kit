---
name: security-review
description: Use after substantial security-impacting implementation changes to review the branch diff for high-confidence vulnerabilities.
---

# Security Review

Use this skill after implementation, before closing a large or
security-relevant task, when the completed diff plausibly changes security
posture.

Good triggers include changes to auth, authorization, parsers, serializers,
template rendering, subprocess execution, filesystem paths, network requests,
secrets handling, logging of sensitive data, dependency loading, CI/CD, release
automation, privileged automation, or user-controlled inputs.

Do not make this a ritual for every task. State why the review is relevant, and
let the user decline unless the repo policy makes it a gate.

## Goal

Identify high-confidence vulnerabilities newly introduced by the branch or task.
This is not a general code review.

## Workflow

1. Establish the review base with `git status`, the current branch, the merge
   base, changed files, commits, and diff.
2. Research repository context before judging findings: security model,
   frameworks, auth patterns, validation helpers, serializers, parsers, shell
   execution, secrets handling, and deployment assumptions.
3. Review only security implications introduced or changed by the diff.
4. Trace user-controlled or untrusted input to sensitive sinks such as database
   queries, template rendering, subprocesses, file paths, deserialization,
   network requests, authz decisions, and secret/logging paths.
5. Report only concrete findings with a clear attack path and at least 8/10
   confidence. Prefer missing a theoretical issue over flooding the user with
   noise.

## High-Signal Categories

- Injection: SQL, command, template, XML/XXE, NoSQL, unsafe deserialization,
  YAML/pickle/eval, XSS through unsafe rendering APIs.
- Authn/authz: bypasses, privilege escalation, session flaws, token validation
  bugs, cross-tenant access.
- Data exposure: PII or secret disclosure, sensitive endpoint leakage, debug
  output exposure.
- Crypto and secrets: weak crypto, bad randomness, certificate validation
  bypass, improper key handling.
- Path and file safety: path traversal or unsafe file operations with untrusted
  input.
- Supply chain and CI/CD: concrete workflow or dependency-loading paths where an
  attacker can control code execution or release artifacts.

## Default Exclusions

- Denial of service, rate limiting, resource exhaustion, regex DoS, memory/CPU
  exhaustion, and file descriptor leaks.
- Theoretical race conditions, lack of hardening, lack of audit logs, log
  spoofing, tabnabbing, generic open redirects, and low-impact XS-Leaks.
- Outdated third-party libraries unless the change introduces the vulnerable
  dependency or execution path.
- Unit tests, examples, and docs unless they ship executable behavior or affect
  production/release safety.
- GitHub Actions concerns without a concrete untrusted-input attack path.
- Shell script command injection unless untrusted input can realistically reach
  the shell command in the intended environment.
- React/Angular XSS unless unsafe APIs such as `dangerouslySetInnerHTML` or
  `bypassSecurityTrustHtml` are used.
- Environment variables and CLI flags as attacker-controlled inputs unless the
  deployment model makes that realistic.

## Output

```markdown
# Security Review

## Findings

### Vuln 1: <category>: `<file>:<line>`
- Severity: High | Medium | Low
- Confidence: <8-10>/10
- Description: <what is vulnerable>
- Exploit scenario: <concrete attack path>
- Recommendation: <specific fix>

## No Findings
If there are no findings, say so explicitly and mention any meaningful residual
risk or skipped context.
```

Focus on high and medium findings. Include low findings only when the user asks
for defense-in-depth review.

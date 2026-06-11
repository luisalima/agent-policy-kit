---
name: security
description: Use for repository-grounded threat modeling before security-relevant architecture work, and focused security review after substantial security-impacting implementation changes.
---

# Security Review And Threat Modeling

Use this skill in two different moments:

- **Threat modeling before architecture work:** suggest it before costly or
  hard-to-reverse decisions that introduce or change trust boundaries, auth,
  authorization, privileged automation, network exposure, data flows,
  multi-tenancy, deployment topology, secrets handling, or third-party
  integrations.
- **Security review after implementation:** suggest it before closing a large or
  security-relevant task when the completed diff plausibly changes security
  posture.

Do not make this a ritual for every task. State why the workflow is relevant,
and let the user decline unless the repo policy makes it a gate.

## Threat Modeling Mode

Goal: produce an actionable AppSec threat model before the architecture becomes
expensive to change.

1. Define scope: repo root, in-scope paths, deployment model, intended users,
   internet exposure, auth expectations, and sensitive data.
2. Ground the system model in repository evidence. Identify runtime components,
   entry points, data stores, external integrations, CI/build tooling, and tests
   separately.
3. Enumerate trust boundaries as concrete edges between components. Note
   protocol, auth, encryption, validation, authorization, and rate limiting when
   there is evidence.
4. List assets that drive risk: credentials, PII, customer data, integrity
   critical state, build artifacts, release permissions, models, config,
   compute resources, and audit logs.
5. State realistic attacker capabilities and non-capabilities. Avoid inflated
   threat assumptions.
6. Enumerate a small set of abuse paths tied to assets and boundaries.
7. Prioritize each threat with likelihood, impact, existing controls, and the
   assumptions that most affect the ranking.
8. Ask 1-3 targeted questions if missing context materially changes the threat
   ranking. If the user cannot answer, record the assumption.
9. Recommend concrete mitigations tied to locations, components, or boundaries.

Threat model output:

```markdown
# Threat Model: <system or path>

## Scope
<in-scope and out-of-scope areas>

## System Model
<components, entry points, data stores, integrations, evidence>

## Trust Boundaries
- <boundary>: <protocol/auth/data/control notes>

## Assets
- <asset>: <why it matters>

## Attacker Capabilities
<capabilities and non-capabilities>

## Threats
### T1. <abuse path>
- Asset: <asset>
- Boundary: <boundary>
- Likelihood: Low | Medium | High
- Impact: Low | Medium | High
- Priority: Low | Medium | High | Critical
- Existing controls: <evidence-backed controls>
- Recommended mitigations: <specific actions>

## Assumptions And Open Questions
- <assumption or question>
```

Write the final Markdown to `<repo-or-path-name>-threat-model.md` unless the
user asks for a different location.

## Security Review Mode

Goal: identify high-confidence vulnerabilities newly introduced by the branch or
task. This is not a general code review.

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

High-signal categories:

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

Default exclusions:

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

Security review output:

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

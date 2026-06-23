---
name: threat-model
description: Use before security-relevant architecture work to model trust boundaries, assets, attacker capabilities, abuse paths, and mitigations.
---

# Threat Model

Use this skill before architecture work, especially before costly or
hard-to-reverse decisions that introduce or change trust boundaries, auth,
authorization, privileged automation, network exposure, data flows,
multi-tenancy, deployment topology, secrets handling, or third-party
integrations.

Do not make this a ritual for every task. State why threat modeling is relevant,
and let the user decline unless the repo policy makes it a gate.

## Goal

Produce an actionable AppSec threat model before the architecture becomes
expensive to change.

## Workflow

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

## Output

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

Write the final Markdown to `docs/threat-models/<repo-or-path-name>.md` unless
the user asks for a different location.

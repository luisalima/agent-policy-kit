---
status: todo
type: task
id: T8
deliverable: docs
created: 2026-06-11
links:
  - https://github.com/anthropics/claude-code-security-review/blob/main/.claude/commands/security-review.md
  - https://github.com/openai/skills/blob/main/skills/.curated/security-threat-model/SKILL.md
---

# T8. Add security review and threat modeling workflow

## Objective
Add a repo-local security workflow that coding agents can use for high-signal
PR security review and repository-grounded threat modeling. The workflow should
adapt the referenced Claude security review command and OpenAI threat modeling
skill into this repo's shared agent-policy-kit conventions, with guidance on
when agents should suggest each workflow.

## What we need to extract / do
- Decide where the workflow belongs in this package, such as a new bundled skill
  or agent command documentation, based on the existing install layout.
- Adapt the PR-diff security review flow to focus on newly introduced,
  concrete vulnerabilities with explicit false-positive filtering and severity
  guidance.
- Adapt the threat modeling flow to enumerate trust boundaries, assets,
  attacker capabilities, abuse paths, assumptions, and mitigations using
  repository evidence.
- Add agent guidance to suggest threat modeling before costly architecture or
  trust-boundary decisions with security implications.
- Add agent guidance to suggest security review at task close when substantial
  completed changes plausibly affect security posture.
- Document expected outputs for both modes, including Markdown finding reports
  and threat model files.
- Update installer, validation, README, and contribution guidance if adding a
  new bundled skill or installable artifact requires it.

## Done when
- The repo contains an installable or documented security workflow covering both
  focused PR security review and threat modeling.
- The workflow tells agents when to suggest threat modeling before architecture
  work and when to suggest security review after implementation.
- The workflow includes concrete scope rules, false-positive filters, severity
  or priority guidance, and output formats.
- Any new packaged artifact is installed for supported agent layouts and covered
  by existing validation or focused tests.
- User-facing docs list the new security workflow and explain how to invoke it.

## Output
Security review and threat modeling workflow artifact plus any installer,
validation, and documentation updates needed to ship it.

## Dependencies
Existing agent-policy-kit skill and installer conventions.

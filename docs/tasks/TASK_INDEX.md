# Task Index

> Frontmatter is the source of truth. This index is a derived view.

## installer

- [x] [T1. Make skill refresh atomic](t1-make-skill-refresh-atomic.md) — `done` → scripts/install.sh, scripts/test-install.sh
- [x] [T2. Support preserved local skill extensions](t2-support-preserved-local-skill-extensions.md) — `done` → scripts/install.sh, scripts/test-install.sh, README.md, CONTRIBUTING.md, templates/AGENTS.md
- [x] [T6. Tighten managed block validation](t6-tighten-managed-block-validation.md) — `done` → scripts/install.sh, scripts/test-install.sh

## release

- [x] [T3. Add a single version source of truth](t3-add-a-single-version-source-of-truth.md) — `done` → VERSION, scripts/validate-version.sh, scripts/test-version.sh, scripts/test-release-install.sh, scripts/release.sh, .github/workflows/ci.yml, README.md, CONTRIBUTING.md
- [x] [T4. Make release script run readiness gates](t4-make-release-script-run-readiness-gates.md) — `done` → scripts/release.sh, scripts/test-release.sh, .github/workflows/ci.yml, CONTRIBUTING.md
- [x] [T5. Run post-release install verification automatically](t5-run-post-release-install-verification-automatically.md) — `done` → .github/workflows/post-release-install.yml, scripts/test-post-release-workflow.sh, .github/workflows/ci.yml

## provenance

- [x] [T7. Run vendored opentasks provenance check in CI](t7-run-vendored-opentasks-provenance-check-in-ci.md) — `done` → .github/workflows/opentasks-provenance.yml, scripts/test-provenance-workflow.sh, .github/workflows/ci.yml, CONTRIBUTING.md

## docs

- [x] [T8. Add security review and threat modeling workflow](t8-add-security-review-and-threat-modeling-workflow.md) — `done` → .agents/skills/security-review/SKILL.md, .agents/skills/threat-model/SKILL.md, .agents/skills/adr/SKILL.md, .agents/skills/done/SKILL.md, templates/AGENTS.md, README.md, scripts/test-install.sh

## policy

- [x] [T9. Add dispatch triggers for slice and spike skills](t9-add-dispatch-triggers-for-slice-and-spike.md) — `done` → templates/AGENTS.md
- [x] [T10. Add explicit never-weaken-tests rule](t10-add-never-weaken-tests-rule.md) — `done` → templates/AGENTS.md
- [x] [T11. Add scope-discipline rule](t11-add-scope-discipline-rule.md) — `done` → templates/AGENTS.md
- [x] [T12. Add dependency policy rule](t12-add-dependency-policy-rule.md) — `done` → templates/AGENTS.md
- [x] [T13. Add destructive-operations rule](t13-add-destructive-operations-rule.md) — `done` → templates/AGENTS.md
- [x] [T14. Add always-on secrets rule](t14-add-always-on-secrets-rule.md) — `done` → templates/AGENTS.md
- [x] [T15. Add bugfix/regression workflow to tdd skill](t15-add-bugfix-regression-workflow-to-tdd.md) — `done` → .agents/skills/tdd/SKILL.md
- [x] [T16. Add read-before-write rule](t16-add-read-before-write-rule.md) — `done` → templates/AGENTS.md
- [x] [T17. Add commit and PR conventions](t17-add-commit-and-pr-conventions.md) — `done` → templates/AGENTS.md
- [x] [T18. Add untrusted-content rule](t18-add-untrusted-content-rule.md) — `done` → templates/AGENTS.md
- [x] [T19. Clarify USER.md vs SKILL.md precedence](t19-clarify-user-md-precedence.md) — `done` → templates/AGENTS.md
- [x] [T20. Move threat-model output location under docs/](t20-move-threat-model-output-to-docs.md) — `done` → .agents/skills/threat-model/SKILL.md
- [x] [T21. Implement opt-in hook enforcement](t21-implement-opt-in-hook-enforcement.md) — `done` → scripts/hooks/, scripts/install.sh, docs/adr/ADR-001-opt-in-hook-enforcement.md

## Open questions

**Answered (history):**
- [x] [Q1. Should the hooks enforcement layer be built or descoped from the proposal?](q1-hooks-enforcement-build-or-descope.md) — `done`

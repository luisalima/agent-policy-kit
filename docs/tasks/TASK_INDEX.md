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

- [x] [T8. Add security review and threat modeling workflow](t8-add-security-review-and-threat-modeling-workflow.md) — `done` → .agents/skills/security/SKILL.md, .agents/skills/adr/SKILL.md, .agents/skills/done/SKILL.md, templates/AGENTS.md, README.md, scripts/test-install.sh

## Open questions

<!-- agent-policy-kit:start -->
## Agent rules

- Before writing source code for any behavior with an assertable contract: use the tdd skill
- When setting up or managing repo task/question tracking in `docs/tasks/`: use the opentasks skill
- When the repo lacks linting for changed code or a new language/toolchain: use the linters skill
- Before security-relevant architecture decisions: suggest threat modeling with the security skill
- Before closing substantial changes that may affect security posture: suggest security review with the security skill
- Before closing any task or raising a PR: use the done skill
- When making a costly or hard-to-reverse architectural decision: use the adr skill
- When using a skill, also read `USER.md` in the same skill directory if it exists; it contains local instructions that extend the package-managed `SKILL.md`
- When blocked, uncertain, or two requirements conflict: stop and ask - never guess
- Tests assert observable behavior, not implementation; they must survive a refactor

## Task and question tracking

This project can use `docs/tasks/` as a lightweight repo convention for work items and open decisions. Use the `opentasks` skill to manage it.

- To initialize task tracking, run `/opentasks bootstrap` where slash skills are supported, `/skill:opentasks bootstrap` in Pi, or invoke the `opentasks` skill through the local skill picker.
- When planning or breaking down work, record concrete steps as tasks and open decisions as questions.
- Keep tasks sized for one focused agent session or one coherent PR.
- Use questions for unresolved decisions, ADRs for durable decisions, and tasks for execution.
- Never create task or question files manually; use the `opentasks` skill so the index stays in sync.
<!-- agent-policy-kit:end -->

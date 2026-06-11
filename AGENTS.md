## Task and question tracking

This project uses `docs/tasks/` as a lightweight repo convention for work items and open decisions. Use the `/opentasks` skill to manage it.

- When planning or breaking down work, record concrete steps as tasks (`/opentasks new task <title>`) and open decisions as questions (`/opentasks new question <title>`).
- Keep tasks sized for one focused agent session or one coherent PR. Split work with multiple outputs, owners, or unresolved decisions.
- Use questions for unresolved decisions, ADRs for durable decisions, and tasks for execution; link ADR-derived tasks back to the ADR in `links:`.
- Keep status current: mark items `doing` when you start, `blocked` when waiting, `done` when complete.
- Never create task or question files manually — always go through `/opentasks` to keep the index in sync.

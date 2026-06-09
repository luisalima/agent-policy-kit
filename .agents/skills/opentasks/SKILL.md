---
name: opentasks
description: "Maintain a lightweight docs/tasks/ repo convention for coding-agent tasks and open questions: bootstrap the folder, create task/question markdown files, update status, close or reopen items, list open work, and rebuild the derived index."
when_to_use: "Use when the user asks to set up a tasks folder, create a task, open a question, close or mark done, mark blocked/doing, reopen an item, show open tasks, list questions, or sync a task index. Trigger phrases include: create a task for X; open a question about Y; close Q3; mark done; set up the tasks folder; show open tasks; add a question about Y."
argument-hint: "[bootstrap | new task <title> | new question <title> | start <item> | block <item> [reason] | done <item> | reopen <item> | list [filter] | sync | status]"
---

# /opentasks — docs/tasks/ convention manager

You are managing a lightweight repo convention in `docs/tasks/`, not an external task manager. The argument you received is:

**$ARGUMENTS**

Parse the intent and execute the appropriate operation below. If the argument is empty or ambiguous, run **status**.

Accept common aliases:
- `init` → `bootstrap`
- `create task`, `add task`, `task` → `new task`
- `open question`, `add question`, `question` → `new question`
- `close`, `finish`, `complete`, `mark done` → `done`

Where an operation accepts `<item>`, resolve it before editing:
1. Exact filename under `docs/tasks/`, with optional `.md`.
2. Exact slug, meaning filename without `.md`.
3. Task shorthand `T<N>` / `t<N>` → the unique task with `id: T<N>` or `t<N>-*.md` filename.
4. Question shorthand `Q<N>` / `q<N>` → the unique `q<N>-*.md` file.
5. Exact case-insensitive title match from the file heading or index line.

If resolution finds no item, stop and tell the user what was searched. If it finds multiple items, stop and ask for the exact slug.

---

## Folder guard

Before executing any operation other than `bootstrap` / `init`, check whether `docs/tasks/` exists. If it does not, stop and tell the user:

> No `docs/tasks/` folder found. Run `/opentasks bootstrap` to set up the system first.

---

## Task sizing and agent behavior

A task should be small enough for one focused agent session or one coherent PR. Good tasks have one objective, concrete `Done when` criteria, independent verification, and no unresolved design choice hidden inside the scope.

Split a task when it has multiple outputs, multiple owners, unresolved decisions, or a title that naturally contains "and then." Do not create tasks for every tiny edit. Create them when work needs to survive chat context, coordinate across humans or agents, or show up in git history.

Agents should create tasks when breaking down a user-approved plan, discovering follow-up work that should not be done immediately, finding a blocker or dependency, extracting implementation work from an ADR, or leaving continuation work for another human or agent. Agents should not create tasks merely to describe work they are already completing in the same turn.

## ADRs and decision flow

Use questions for unresolved decisions, ADRs for durable decisions, and tasks for execution:

```text
Q<N> -> ADR -> T<N>
```

- Open `Q<N>` when a decision is unresolved.
- Create or update an ADR when the answer has architectural or long-lived consequences.
- Close the question with the decision and link to the ADR.
- Create tasks for the implementation work that follows from the ADR.
- Link ADR-derived tasks back to the ADR using `links:`.
- If a task uncovers a durable decision, open a question and block or split the task until the ADR resolves it.
- If implementation shows the ADR is wrong or incomplete, open a new question instead of silently changing task scope.

---

## Operations

### `bootstrap` / `init`
Set up a fresh `docs/tasks/` folder in a new project.
1. Ask the user for the project's deliverable names if not obvious from context (e.g. D1, D2, ops).
2. Confirm what language the project documentation is in (default to English if obvious).
3. Create `docs/tasks/README.md` — a human-readable conventions doc. See **§README** below for required content.
4. Create `docs/tasks/TASK_INDEX.md` — empty index with group headers for each deliverable + Open questions section. See **§INDEX** below for format.
5. Do NOT create any tasks or questions yet.
6. Append the following block to `AGENTS.md` (create it if absent) only if it does not already contain a `## Task and question tracking` section. If `CLAUDE.md` exists and does not already contain that section, append the same block there too.

```markdown
## Task and question tracking

This project uses `docs/tasks/` as a lightweight repo convention for work items and open decisions. Use the `/opentasks` skill to manage it.

- When planning or breaking down work, record concrete steps as tasks (`/opentasks new task <title>`) and open decisions as questions (`/opentasks new question <title>`).
- Keep tasks sized for one focused agent session or one coherent PR. Split work with multiple outputs, owners, or unresolved decisions.
- Use questions for unresolved decisions, ADRs for durable decisions, and tasks for execution; link ADR-derived tasks back to the ADR in `links:`.
- Keep status current: mark items `doing` when you start, `blocked` when waiting, `done` when complete.
- Never create task or question files manually — always go through `/opentasks` to keep the index in sync.
```

---

### `new task <title>`
Create a new task file.
1. Find the next task number N: scan existing `t<N>-*.md` files and task frontmatter `id: T<N>`, take max N + 1 (start at 1 if none exist). Task IDs are monotonic and never reused.
2. Generate a kebab-case slug from the title (ASCII, lowercase, hyphens; strip accents, replace spaces with hyphens).
3. Check task size before creating it. If the title or context implies multiple outputs, multiple owners, unresolved decisions, or "and then" sequencing, split it into smaller tasks or create a question for the unresolved decision first.
4. If `docs/tasks/t<N>-<slug>.md` already exists, abort and tell the user the file exists — suggest they pick a different title or run `/opentasks status` to see the existing item.
5. Determine the deliverable bucket from context or ask the user.
6. If the task comes from an ADR, include the ADR path in `links:`.
7. Write `docs/tasks/t<N>-<slug>.md` with this exact structure:

```markdown
---
status: todo
type: task
id: T<N>
deliverable: <D1|D2|ops|…>
created: <YYYY-MM-DD>
links: []
---

# T<N>. <Title>

## Objective
<One or two sentences — what this is and why it matters.>

## What we need to extract / do
<Concrete bullets describing the actual work.>

## Done when
- <Concrete, observable completion criterion.>

## Output
<What gets produced and where it feeds into. Write "none" if the task produces no tracked artifact.>

## Dependencies
<What must exist first.>
```

8. For ADR-derived tasks, replace `links: []` with a YAML list containing the ADR path.
9. Add a line to `TASK_INDEX.md` under the correct `## <Deliverable>` group:
   `- [ ] [T<N>. <Title>](t<N>-<slug>.md) — \`todo\``

---

### `new question <title>`
Create a new question file.
1. Find the next question number N: scan existing `q<N>-*.md` files, take max N + 1 (start at 1 if none exist).
2. Generate a kebab-case slug from the title.
3. Ask the user for `owner` if not clear from context (who needs to answer — a person or role).
4. Write `docs/tasks/q<N>-<slug>.md`:

```markdown
---
status: todo
type: question
owner: <name-or-role>
created: <YYYY-MM-DD>
---

# Q<N>. <The question, phrased as a question>

**Why it matters:** <impact on design / scope>
- Branch A → consequence A.
- Branch B → consequence B.

**Still open:** <what remains unclear>
```

5. Add a line to `TASK_INDEX.md` under `## Open questions`, sub-grouped by owner:
   `- [ ] [Q<N>. <Title>](q<N>-<slug>.md) — \`todo\``

---

### `start <item>`
1. Resolve `<item>` and open the matching file.
2. If the file has `type: question` in frontmatter, abort and tell the user: questions don't use `doing` status — use `/opentasks block` to flag as waiting, or `/opentasks done` to record the answer.
3. If `status: done`, abort and tell the user to run `/opentasks reopen <item>` first.
4. Change `status: todo` or `status: blocked` → `status: doing` in frontmatter. If it is already `doing`, leave it as-is.
5. Add `started: <YYYY-MM-DD>` to frontmatter directly after `status` if absent. Do not duplicate or overwrite an existing `started:`.
6. If a `## Blocker` section is present and the blocker is no longer relevant, remove it or add a short resolved note.
7. Update the index line: replace the current status tag with `` `doing` `` and remove any `(waiting on ...)` suffix.

---

### `block <item> [reason]`
1. Resolve `<item>` and open the matching file.
2. If `status: done`, abort and tell the user to run `/opentasks reopen <item>` first.
3. Change status → `status: blocked` in frontmatter. If it is already `blocked`, leave it as-is.
4. Add or update a single `## Blocker` section in the body explaining what's being waited on. If no reason was provided and it is not obvious from context, ask for the blocker.
5. Update the index line: replace the current status tag with `` `blocked` `` and append `(waiting on <reason>)` if a reason was given.

---

### `done <item>`
1. Resolve `<item>` and open the matching file.
2. If the item is already `done`, leave existing answer/output/closed fields unchanged unless the user explicitly asks to correct them, then skip to the `TASK_INDEX.md` update.
3. Before editing, validate the closure:
   - **If it's a question:** if the answer is not clear from context, ask for it before closing.
   - **If it's a task:** check the `## Done when` section. If the criteria are clearly unmet or ambiguous, stop and report what remains unless the user explicitly asked to close it anyway.
4. Set `status: done`, add `closed: <YYYY-MM-DD>` to frontmatter if absent, and do not duplicate an existing `closed:`.
5. **If it's a question:** add the answer inline in the body with date and source. Do not replace the question text.
6. **If it's a task that produced a tracked artifact:** add or update `output: <path>` in frontmatter. Omit `output:` entirely if the task produced no tracked artifact.
7. In `TASK_INDEX.md`:
   - Flip `[ ]` → `[x]` on the item's line.
   - Replace status tag with `` `done` ``.
   - For tasks with an output: append `→ <output-path>`.
   - For questions: move the line to the `**Answered (history):**` sub-group under `## Open questions`.

---

### `reopen <item>`
Reopen a previously closed item.
1. Resolve `<item>` and open the matching file.
2. Set `status: todo` in frontmatter.
3. Remove the `closed:` field from frontmatter. For tasks, also remove `output:` because the prior output is no longer the current completion artifact. Leave `started:` in place if present — it records prior work.
4. In `TASK_INDEX.md`:
   - Flip `[x]` → `[ ]` on the item's line.
   - Replace `` `done` `` with `` `todo` ``.
   - Remove any `→ output-path` suffix from the line.
   - For questions: move the line back from `**Answered (history):**` to the active sub-group under `## Open questions`.

---

### `list [filter]`
Read `docs/tasks/` and print a filtered view. Accepts one optional argument:

| Filter | What it shows |
|---|---|
| _(none)_ | All non-done items, grouped by deliverable / owner |
| `todo` / `doing` / `blocked` / `done` | Items with that exact status |
| `<deliverable>` (e.g. `D1`, `ops`) | All items in that deliverable bucket |
| `questions` | All question files regardless of status |

Output format: same grouped list style as the index — one item per line with checkbox and status tag. Print a count summary at the bottom.

---

### `sync`
Rebuild `TASK_INDEX.md` from scratch by reading all files in `docs/tasks/`.
1. Read frontmatter from every `*.md` file except `README.md` and `TASK_INDEX.md`.
2. Group `type: task` files by `deliverable`; group `type: question` files by `owner`. Prefer the task `id` field for labels and sorting; fall back to the filename only for legacy task files.
3. For backward compatibility, treat files with no `type` and a `deliverable` as tasks, but report them as frontmatter mismatches. Also report task files missing `id: T<N>` as legacy task files that should be migrated.
4. Emit the full index in the format defined in **§INDEX**.
5. Frontmatter is the source of truth — discard the old index content entirely.

---

### `status` (default when no argument given)
Read `TASK_INDEX.md` (or scan `docs/tasks/` if the index is absent) and report:
- Count of items by status: todo / doing / blocked / done.
- All `doing` and `blocked` items with their blockers.
- Any frontmatter/index mismatches spotted, including missing `type`, invalid statuses, questions marked `doing`, tasks missing `id`, tasks missing `deliverable`, questions missing `owner`, duplicate task IDs, duplicate question numbers, malformed `links`, and stale index lines.

---

## File naming rules

- Task slugs: `t<N>-<short-slug>`. Examples: `t1-llm-shortlist`, `t8-extract-analysis-scripts`.
- Question slugs: `q<N>-<short-slug>`. Examples: `q1-classification-rubric`, `q7-template-wording`.
- All filenames are lowercase ASCII — strip accents, replace spaces with hyphens.
- Task and question numbers are monotonic across the project lifetime. Never reuse a number.

---

## Status semantics

| Status    | Tasks                        | Questions                      |
|-----------|------------------------------|--------------------------------|
| `todo`    | Not started                  | Ready to ask / discuss         |
| `doing`   | In progress                  | Not valid — use `block` or `done` directly |
| `blocked` | Waiting on dependency        | Waiting for an answer          |
| `done`    | Completed                    | Answered                       |

---

## Frontmatter reference

**Tasks:**
```yaml
---
status: todo            # todo | doing | blocked | done
type: task
id: T<N>                # stable task identifier, monotonic and never reused
deliverable: D2         # project-specific bucket
created: YYYY-MM-DD
links: []               # optional related URLs or repo paths
started: YYYY-MM-DD     # added by `start`; kept on reopen as historical record
closed: YYYY-MM-DD      # only when status = done; removed by `reopen`
output: path/to/file.md # only if the task produced a tracked artifact
---
```

**Questions:**
```yaml
---
status: todo            # todo | blocked | done  (never doing)
type: question
owner: <name-or-role>
created: YYYY-MM-DD
closed: YYYY-MM-DD      # only when status = done; removed by `reopen`
---
```

---

## §README — what `docs/tasks/README.md` must cover

Write the README in the same language as the project's documentation. It must include:

1. One-paragraph intro: this folder is a lightweight repo convention for both execution tasks and open questions using flat markdown + YAML frontmatter; item type is distinguished by the `type` frontmatter field.
2. How it works: one file per item; frontmatter is the source of truth; `TASK_INDEX.md` is a derived view; tasks have stable `T<N>` identifiers.
3. The four status values and what they mean for tasks vs questions (see table above).
4. Type conventions: task vs question; what `owner` is for; what `links` is for.
5. Task sizing guidance: one focused agent session or one coherent PR; split work with multiple outputs, owners, unresolved decisions, or "and then" sequencing.
6. Agent creation guidance: create tasks for user-approved plans, deferred follow-up work, blockers, ADR implementation work, and handoffs; do not create tasks merely to describe same-turn work.
7. ADR and decision flow: `Q<N> -> ADR -> T<N>`, plus the reverse path when a task uncovers a durable decision; ADR-derived tasks link back to the ADR in `links:`.
8. The full task body template as a fenced markdown block.
9. The full question body template as a fenced markdown block.
10. Workflow: create → start → block → close → reopen, with the exact frontmatter changes at each step.
11. A note that closed files are kept as history — never delete.
12. A short note that this is not a task manager, Kanban board, daemon, database, sync service, or UI.

---

## §INDEX — `TASK_INDEX.md` format

```markdown
> Frontmatter is the source of truth. This index is a derived view — if they disagree, read the individual .md files.

## D1 — <Deliverable name>

- [ ] [T1. <Title>](t1-slug.md) — `todo`
- [ ] [T2. <Title>](t2-slug.md) — `blocked` (waiting on client data)
- [x] [T3. <Title>](t3-slug.md) — `done` → path/to/output.md

## D2 — <Deliverable name>

…

## Open questions

**For <person A>:**
- [ ] [Q1. <Question>](q1-slug.md) — `todo`

**For <person B>:**
- [ ] [Q2. <Question>](q2-slug.md) — `blocked`

**Answered (history):**
- [x] [Q3. <Question>](q3-slug.md) — `done`
```

Rules:
- `[x]` only when `status: done`. All other statuses use `[ ]` (including `blocked`).
- Task lines include the stable task ID in the visible label, e.g. `T4. Implement cache`.
- `blocked` items may have a parenthetical explanation: `(waiting on client data)`.
- Append `→ path/to/output` for `done` tasks that produced a tracked artifact.
- Closed files are never deleted — they remain in the folder and in the index as history.

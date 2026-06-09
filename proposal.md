# agent-policy-kit — Lazy-Loading Proposal

Convert the monolithic AGENTS.md into a shared dispatch table plus tool-specific
adapters, so policy content only enters context when it's actually needed.

---

## Architecture

| Layer | File(s) | Loads when |
|---|---|---|
| Shared dispatch table | `AGENTS.md` | Codex, Amp, Pi, and other AGENTS-aware tools |
| Claude adapter | `CLAUDE.md` | Every Claude Code turn |
| Workflow skills | `.agents/skills/<name>/SKILL.md`, copied to `.claude/skills/<name>/SKILL.md` for Claude | Skill is invoked |
| Hard enforcement | `.codex/hooks.json`, `.claude/settings.json`, shared `scripts/hooks/*` | Event fires |

---

## 1. Shared dispatch table

```markdown
## Agent rules

- Before writing source code for any behavior with an assertable contract: use the tdd skill
- When setting up or managing repo task/question tracking in `docs/tasks/`: use the opentasks skill
- Before closing any task or raising a PR: use the done skill
- When making a costly or hard-to-reverse architectural decision: use the adr skill
- When blocked, uncertain, or two requirements conflict: stop and ask — never guess
- Tests assert observable behavior, not implementation; they must survive a refactor
```

Six lines. The detailed workflow lives in the skills below.

Keep `AGENTS.md` as the canonical shared source. Codex, Amp, and Pi read it
directly. Claude Code uses `CLAUDE.md`, so add a tiny adapter:

```markdown
# Claude project instructions

Follow the shared project policy in @AGENTS.md.
```

If `@AGENTS.md` imports are not available in a Claude environment, duplicate the
six-line dispatch table in `CLAUDE.md` instead. Do not maintain two different
policies.

---

## 2. Skills

Author each workflow once as an Agent Skill under `.agents/skills/`, then copy
it into Claude's `.claude/skills/` adapter path during install.

Recommended repo layout:

```text
.agents/skills/opentasks/SKILL.md # Codex, Amp, Pi
.agents/skills/tdd/SKILL.md
.agents/skills/done/SKILL.md
.agents/skills/adr/SKILL.md
.agents/skills/spike/SKILL.md
.agents/skills/slice/SKILL.md

.claude/skills/opentasks/SKILL.md # Claude Code adapter copy
.claude/skills/tdd/SKILL.md
.claude/skills/done/SKILL.md
.claude/skills/adr/SKILL.md
.claude/skills/spike/SKILL.md
.claude/skills/slice/SKILL.md
```

Claude also supports the older `.claude/commands/<name>.md` custom-command
layout. Use that only if you need command compatibility; prefer skill
directories for cross-agent sharing.

Invocation differs by tool:

- Claude Code: `/opentasks`, `/tdd`, `/done`, `/adr`, etc.
- Codex: select the skill with `/skills`, mention `$opentasks`, or let Codex invoke it from the skill description.
- Amp: use the skill from `.agents/skills/` according to Amp's skill invocation flow.
- Pi: `/skill:opentasks`, `/skill:tdd`, `/skill:done`, etc.

### `opentasks` — Manage repo task/question tracking

```markdown
---
name: opentasks
description: "Maintain a lightweight docs/tasks/ repo convention for coding-agent tasks and open questions: bootstrap the folder, create task/question markdown files, update status, close or reopen items, list open work, and rebuild the derived index."
when_to_use: "Use when the user asks to set up a tasks folder, create a task, open a question, close or mark done, mark blocked/doing, reopen an item, show open tasks, list questions, or sync a task index. Trigger phrases include: create a task for X; open a question about Y; close Q3; mark done; set up the tasks folder; show open tasks; add a question about Y."
argument-hint: "[bootstrap | new task <title> | new question <title> | start <item> | block <item> [reason] | done <item> | reopen <item> | list [filter] | sync | status]"
---

Manage a lightweight repo convention in `docs/tasks/`, not an external task
manager. Main operations:

- `/opentasks bootstrap` sets up `docs/tasks/README.md` and `docs/tasks/TASK_INDEX.md`.
- `/opentasks new task <title>` creates a numbered `t<N>-<slug>.md` task.
- `/opentasks new question <title>` creates a numbered `q<N>-<slug>.md` question.
- `/opentasks start|block|done|reopen <item>` updates item status.
- `/opentasks list [filter]`, `/opentasks sync`, and `/opentasks status` report or rebuild the derived index.

Use questions for unresolved decisions, ADRs for durable decisions, and tasks for
execution: `Q<N> -> ADR -> T<N>`.
```

---

### `tdd` — TDD discipline

```markdown
---
name: tdd
description: Use before writing source code for behavior with an assertable contract. Do not use for pure formatting, docs-only edits, or declared exploratory spikes.
---

Walk the TDD cycle for the current task:

1. Identify the behavior to assert. If unclear, ask before proceeding.
2. Write the failing test FIRST. Show what it asserts and why.
3. Run the suite. Confirm the new test fails — for the right reason, not a
   typo or import error. If it passes immediately, something is wrong — stop.
4. Write the minimum source to make it pass. No extras.
5. Run the suite again. Confirm green.
6. Commit with a focused message.

### Spike exception
If the behavior is unknown (UI layout, unfamiliar API, prompt engineering):
1. Declare the spike up front: "Spike to learn X; I'll discard and TDD after."
2. Isolate it — never mix into the production change.
3. Show the discard before the real implementation lands.
An undeclared deviation is not a spike — it's skipped tests.
```

---

### `done` — Definition of done checklist

```markdown
---
name: done
description: Use before closing a task, raising a PR, pushing, or reporting completion.
---

Check every item before closing the task or raising a PR:

- [ ] Suite green, linter clean — no failing or skipped tests, no lint errors
- [ ] New behavior has a test that failed before the fix and passes after
- [ ] Docs and ADRs updated where warranted
- [ ] No secrets or credentials staged
- [ ] Change committed to a working branch (not main)
- [ ] Result is demonstrable end-to-end

Do not stop short of this list. Do not keep polishing past it.
```

---

### `adr` — Architectural Decision Record

```markdown
---
name: adr
description: Use when a costly or hard-to-reverse architectural decision is being made.
---

Write an ADR when a decision is:
- Costly to reverse
- Constrains future choices
- Picks between viable alternatives a maintainer would question

Routine, reversible choices don't need one.

Template:
## ADR-NNN: <title>

**Date:** <date>  
**Status:** Proposed | Accepted | Superseded

### Context
<what forced this decision>

### Decision
<what we chose>

### Alternatives considered
<what else was viable and why it was rejected>

### Consequences
<what becomes easier, harder, or constrained>
```

---

### `spike` — Declare a spike

```markdown
---
name: spike
description: Use when behavior is not yet known and exploratory work is needed before TDD.
---

A spike is exploratory work where you don't yet know what the behavior should be.

Before starting:
1. State the learning goal: "Spike to learn X"
2. Confirm it will be discarded — never merged into production
3. Name what the real TDD implementation will look like afterward

After the spike:
- Show the discard explicitly
- Start the real implementation from scratch with the tdd skill
```

---

### `slice` — Scope a vertical slice

```markdown
---
name: slice
description: Use before planning implementation to define the smallest demonstrable vertical slice.
---

Before planning implementation, define the smallest vertical slice:
- What can a user/caller do after this slice that they couldn't before?
- Does it touch every layer needed to be demonstrable end-to-end?
- Is there a smaller slice that still delivers observable value?

Each step in the plan should be demonstrable on its own.
Never plan horizontal layers (all models first, then all controllers, etc.).
```

---

## 3. Hooks (hard enforcement)

Hooks are not portable by file path. Keep the hook logic in shared scripts, then
wire each agent to those scripts through its native config.

Recommended shared scripts:

```text
scripts/hooks/check_git_push.py
scripts/hooks/check_secret_edit.py
```

Each script reads the hook JSON from stdin when available, inspects the relevant
command or edit payload, prints a concise warning for soft policy violations, and
exits non-zero only for hard blocks.

### Claude Code

In `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR/scripts/hooks/check_git_push.py\""
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$CLAUDE_PROJECT_DIR/scripts/hooks/check_secret_edit.py\""
          }
        ]
      }
    ]
  }
}
```

Claude command hooks receive structured JSON on stdin. Avoid relying on ad hoc
environment variables for hook input.

### Codex

In `.codex/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$(git rev-parse --show-toplevel)/scripts/hooks/check_git_push.py\"",
            "statusMessage": "Checking push policy"
          }
        ]
      },
      {
        "matcher": "Edit|Write|apply_patch",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$(git rev-parse --show-toplevel)/scripts/hooks/check_secret_edit.py\"",
            "statusMessage": "Checking edit for secrets"
          }
        ]
      }
    ]
  }
}
```

Codex project-local hooks must be reviewed and trusted before they run. Use
`/hooks` to inspect and trust them in the current session.

---

## Rule → mechanism mapping

| Rule | Mechanism | Rationale |
|---|---|---|
| 1. TDD discipline | `tdd` skill + shared dispatch trigger | Workflow with steps; dispatched by `AGENTS.md`/`CLAUDE.md` |
| 2. Open tasks | `opentasks` skill + shared dispatch trigger | Repo-native `docs/tasks/` convention for durable tasks and open questions |
| 3. Tests assert intent | AGENTS.md (1 line) | Mindset rule; must influence every test written |
| 4. Never weaken tests | AGENTS.md (implicit in rule 3) | Same mindset; no better hook event |
| 5. Version control / push gate | Agent-specific hook + `done` skill | Hard check on push; checklist for the rest |
| 6. Read before write | Shared dispatch or agent default | Mindset rule; keep it always-on only if the old policy required it |
| 7. Vertical slices | `slice` skill + shared dispatch trigger | Planning workflow |
| 8. Testing the CLI | Part of `tdd` | Covered under TDD cycle |
| 9. Stop when blocked | AGENTS.md (1 line) | Mindset; must be always-on |
| 10. Build supporting tools | Drop | Too situational; not worth a skill |
| 11. Definition of done | `done` skill + shared dispatch trigger | Checklist; dispatched by `AGENTS.md`/`CLAUDE.md` |
| 12. ADRs | `adr` skill + shared dispatch trigger | Template + criteria; lazy-loaded |

---

## What this buys you

**Before:** each agent loads the full policy every turn, whether or not any of
it is relevant to "fix this typo."

**After:** `AGENTS.md` holds the canonical six-line policy, `CLAUDE.md` only
adapts Claude Code to that shared policy, and each workflow loads only when its
skill is used. Hooks enforce the mechanical checks through each agent's native
hook system while sharing the underlying script logic.

Context budget spent on policy drops sharply for routine tasks without making
the policy Claude-only or Codex-only.

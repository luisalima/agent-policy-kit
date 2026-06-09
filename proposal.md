# Agent Operating Policy — Lazy-Loading Proposal

Convert the monolithic AGENTS.md into three layers so policy content only enters
context when it's actually needed.

---

## Architecture

| Layer | File(s) | Loads when |
|---|---|---|
| Dispatch table | `AGENTS.md` | Every turn (kept tiny) |
| Workflow skills | `.claude/commands/*.md` | Skill is invoked |
| Hard enforcement | `.claude/settings.json` hooks | Event fires (unconditional) |

---

## 1. Trimmed AGENTS.md (dispatch table only)

```markdown
## Agent rules

- Before writing source code for any behavior with an assertable contract: invoke /tdd
- Before closing any task or raising a PR: invoke /done
- When making a costly or hard-to-reverse architectural decision: invoke /adr
- When blocked, uncertain, or two requirements conflict: stop and ask — never guess
- Tests assert observable behavior, not implementation; they must survive a refactor
```

Five lines. The detailed workflow lives in the skills below.

> Note: Claude Code reads `AGENTS.md`; other agents (Cursor, Codex, etc.) read `AGENTS.md`.
> If you use Claude Code exclusively, symlink or duplicate as needed.

---

## 2. Skills

Each file lives at `.claude/commands/<name>.md` and is invoked with `/<name>`.

### `/tdd` — TDD discipline

```markdown
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

### `/done` — Definition of done checklist

```markdown
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

### `/adr` — Architectural Decision Record

```markdown
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

### `/spike` — Declare a spike

```markdown
A spike is exploratory work where you don't yet know what the behavior should be.

Before starting:
1. State the learning goal: "Spike to learn X"
2. Confirm it will be discarded — never merged into production
3. Name what the real TDD implementation will look like afterward

After the spike:
- Show the discard explicitly
- Start the real implementation from scratch with /tdd
```

---

### `/slice` — Scope a vertical slice

```markdown
Before planning implementation, define the smallest vertical slice:
- What can a user/caller do after this slice that they couldn't before?
- Does it touch every layer needed to be demonstrable end-to-end?
- Is there a smaller slice that still delivers observable value?

Each step in the plan should be demonstrable on its own.
Never plan horizontal layers (all models first, then all controllers, etc.).
```

---

## 3. Hooks (hard enforcement)

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
            "command": "bash -c 'echo \"$CLAUDE_TOOL_INPUT\" | grep -qE \"git push\" && echo \"HOOK: run /done before pushing — suite must be green and no secrets staged\" || true'"
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'echo \"$CLAUDE_TOOL_INPUT\" | grep -qiE \"(password|secret|api_key|token|private_key)\" && echo \"HOOK: possible credential in edit — review before proceeding\" || true'"
          }
        ]
      }
    ]
  }
}
```

Hook output is injected into the conversation. Claude sees it and must respond.
For a hard block (not just a warning), exit with a non-zero code.

---

## Rule → mechanism mapping

| Rule | Mechanism | Rationale |
|---|---|---|
| 1. TDD discipline | `/tdd` skill + AGENTS.md trigger | Workflow with steps; dispatched by AGENTS.md |
| 2. Tests assert intent | AGENTS.md (1 line) | Mindset rule; must influence every test written |
| 3. Never weaken tests | AGENTS.md (implicit in rule 2) | Same mindset; no better hook event |
| 4. Version control / push gate | Hook (PreToolUse on Bash) + `/done` | Hard check on push; checklist for the rest |
| 5. Read before write | AGENTS.md (existing default behavior) | Already Claude's default; no hook needed |
| 6. Vertical slices | `/slice` skill + AGENTS.md trigger | Planning workflow |
| 7. Testing the CLI | Part of `/tdd` | Covered under TDD cycle |
| 8. Stop when blocked | AGENTS.md (1 line) | Mindset; must be always-on |
| 9. Build supporting tools | Drop — covered by AGENTS.md defaults | Too situational; not worth a skill |
| 10. Definition of done | `/done` skill + AGENTS.md trigger | Checklist; dispatched by AGENTS.md |
| 11. ADRs | `/adr` skill + AGENTS.md trigger | Template + criteria; lazy-loaded |

---

## What this buys you

**Before:** AGENTS.md loads ~60 lines of policy every turn, whether or not any of
it is relevant to "fix this typo."

**After:** AGENTS.md loads 5 lines every turn. The TDD workflow (15 lines) only
enters context when source code is about to be written. The ADR template (20 lines)
only enters context when an architectural decision is in play. Hooks enforce the
non-negotiables unconditionally.

Context budget spent on policy drops ~90% for routine tasks.

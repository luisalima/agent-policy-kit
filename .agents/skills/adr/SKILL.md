---
name: adr
description: Use when a costly or hard-to-reverse architectural decision is being made.
---

# Architectural Decision Record

Write an ADR when a decision is:

- Costly to reverse
- Constrains future choices
- Picks between viable alternatives a maintainer would question

Routine, reversible choices do not need one.

Use this template:

```markdown
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

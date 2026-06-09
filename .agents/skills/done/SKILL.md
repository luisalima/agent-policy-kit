---
name: done
description: Use before closing a task, raising a PR, pushing, or reporting completion.
---

# Definition Of Done

Check every item before closing the task or raising a PR:

- [ ] Suite green, linter clean: no failing or skipped tests, no lint errors
- [ ] New behavior has a test that failed before the fix and passes after
- [ ] Docs and ADRs updated where warranted
- [ ] No secrets or credentials staged
- [ ] Change is on a working branch, not main
- [ ] Result is demonstrable end-to-end

Do not stop short of this list. Do not keep polishing past it.

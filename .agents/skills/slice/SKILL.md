---
name: slice
description: Use before planning implementation to define the smallest demonstrable vertical slice.
---

# Vertical Slice

Before planning implementation, define the smallest vertical slice:

- What can a user or caller do after this slice that they could not before?
- Does it touch every layer needed to be demonstrable end-to-end?
- Is there a smaller slice that still delivers observable value?

Each step in the plan should be demonstrable on its own.

Avoid horizontal plans such as all models first, then all controllers, then all UI.

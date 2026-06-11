# Task And Question Tracking

This folder tracks durable implementation work and open decisions for this repo.
Each task or question lives in one Markdown file with YAML frontmatter.

`TASK_INDEX.md` is a derived index for scanning current work. The item files are
the source of truth.

## Conventions

- Tasks use `t<N>-<slug>.md` filenames and stable `T<N>` IDs.
- Questions use `q<N>-<slug>.md` filenames and stable `Q<N>` IDs.
- Keep tasks small enough for one focused session or one coherent PR.
- Put concrete, observable completion criteria in `## Done when`.
- Use `todo`, `doing`, `blocked`, or `done` for task status.
- Use `todo`, `blocked`, or `done` for question status.

## Deliverables

- `installer`: installer behavior, update safety, and install tests.
- `release`: release process, versioning, and public install verification.
- `provenance`: vendored upstream verification and supply-chain checks.
- `docs`: user-facing docs and contribution guidance.

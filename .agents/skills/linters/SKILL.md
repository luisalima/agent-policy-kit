---
name: linters
description: Use when a repo lacks a lint command for changed code, when adding a new language/toolchain, or when asked to improve static checks. Add relevant linters conservatively, using existing project tooling first, and avoid adding dependencies without a clear project fit.
---

# Linters

Add or improve static checks that match the repository's languages, package managers, and existing conventions.

## Workflow

1. Inspect the project before choosing tools:
   - Existing scripts: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, CI files, pre-commit config.
   - Existing formatters, test commands, and dependency managers.
   - Languages touched by the current task.
2. Prefer existing tooling:
   - If a lint command exists, run it and improve configuration only when needed.
   - If a nearby package/module already has a linter, mirror that pattern.
3. Add the smallest relevant lint setup:
   - JavaScript/TypeScript: ESLint or the repo's existing framework lint command.
   - Python: Ruff by default, unless the repo already uses Flake8, Pylint, Black, or mypy.
   - Go: `gofmt`/`go vet`, and `golangci-lint` only when the repo already expects it or asks for it.
   - Rust: `cargo fmt` and `cargo clippy`.
   - Ruby: RuboCop when the repo uses Bundler/Ruby conventions.
   - Shell: ShellCheck when shell scripts are part of the repo.
4. Wire the linter into the project:
   - Add or update a `lint` script, Make target, task runner entry, or CI step that matches existing conventions.
   - Document the command in `AGENTS.md` only if agents need to run it regularly.
5. Verify:
   - Run the new or updated lint command.
   - Fix reported issues only when in scope.
   - If lint failures are pre-existing and broad, report them and avoid mixing a large cleanup into unrelated work.

## Rules

- Do not add a linter just because one exists for the language. Add it when it protects changed code or a missing project check.
- Do not introduce a new package manager or build system for linting.
- Do not replace an established linter without an explicit reason.
- Do not weaken lint rules to make the current change pass unless the rule is clearly wrong for the project.
- Keep formatter and linter responsibilities separate unless the chosen tool intentionally covers both.
- Prefer a focused follow-up task over broad lint cleanup when failures are unrelated.

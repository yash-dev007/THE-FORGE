# THE FORGE kit — changelog

Adopted repos track their own hypothesis history in `PROJECT_LOG.md`.
This file tracks **kit-level** revisions (templates, scripts, docs).

When `templates/universal/CLAUDE.md` is updated, bump its `Kit template revision:`
footer. Adopted repos should re-run `scripts/forge-update.*` to pull the latest
`CLAUDE.md` and Claude Code integration files.

---

## v3.2 — 2026-04-13

### Added
- `templates/gemini-cli/GEMINI.md` — Gemini CLI bridge file for adopted repos
  (startup gate, `run_shell_command`-based EVAL.sh runner, `read_file`-based
  Obsidian pattern access)
- `scripts/forge-adopt.sh` + `forge-adopt.ps1` — now copies `templates/gemini-cli/GEMINI.md`
  into the target repository root automatically
- `scripts/forge-update.sh` + `forge-update.ps1` — now refreshes `GEMINI.md`
  in already-adopted repos
- `docs/ADOPT.md` — updated Step 7b to include Gemini CLI integration

### Changed
- `README.md` — added Gemini CLI to supported agents badge and description
- `docs/KIT_LAYOUT.md` — documented `GEMINI.md` in root and `templates/gemini-cli/`

---

## v3.1 — 2026-04-12

### Added
- `CLAUDE.md` at kit root — Claude Code workspace context (do not confuse with
  the adopted-repo template at `templates/universal/CLAUDE.md`)
- `templates/claude-code/CLAUDE.md` — Claude Code bridge file for adopted repos
  (startup gate, Bash-based EVAL.sh runner, Obsidian file-read pattern)
- `templates/claude-code/settings.json` — example Claude Code hooks/settings
- `scripts/forge-update.sh` + `forge-update.ps1` — refresh templates in an
  already-adopted repo without overwriting project state
- `docs/CUSTOMIZING_EVAL.md` — guide for wiring real PERF_SCORE benchmarks
  per stack (pytest-benchmark, autocannon, go test -bench, hyperfine)
- `docs/OBSIDIAN_SETUP.md` — vault setup, co-location options, Claude Code
  file-read pattern, pattern promotion workflow
- `docs/CHANGELOG.md` — this file

### Changed
- `templates/stacks/node/EVAL.sh` — DEBT_SCORE now measured via ESLint complexity
  rule (CC > 10 violations); no longer a static placeholder
- `templates/stacks/go/EVAL.sh` — DEBT_SCORE now measured via `gocyclo -over 10`;
  no longer a static placeholder
- `templates/stacks/python/EVAL.sh` — added PERF_SCORE benchmark comment block
- `templates/stacks/node/EVAL.sh` — added PERF_SCORE benchmark comment block
- `templates/stacks/go/EVAL.sh` — added PERF_SCORE benchmark comment block
- `templates/stacks/node/EVAL_SPEC.md` — documents eslint complexity tool and
  gocyclo-equivalent; lists optional tools
- `templates/stacks/go/EVAL_SPEC.md` — documents gocyclo; lists optional tools
- `templates/universal/FORGE_SYSTEM.md.template` — expanded from 3 bare sections
  to 6 structured sections aligned with Auditor Protocol questions
- `docs/ADOPT.md` — added Step 6b (Claude Code integration); updated script
  output descriptions
- `scripts/forge-adopt.sh` + `forge-adopt.ps1` — now copies `templates/claude-code/`
  into `<target>/.claude/` automatically
- `docs/KIT_LAYOUT.md` — documents `templates/claude-code/`, `scripts/forge-update.*`,
  and new docs
- `README.md` — updated quick links; added FORGE_VERSION; forge-update in scripts
- `FORGE_MAINTAINER.md` — updated work summary and changelog entry

---

## v3.0 — 2026-04-12 (initial Cursor build)

### Added
- Initial multi-project kit: `templates/`, `scripts/`, `docs/`, `Forge/` layout
- `templates/universal/CLAUDE.md` — v3 text adapted for multi-project use
- Quintet templates: `FORGE_IDENTITY.md`, `RESEARCH.md`, `FORGE_SYSTEM.md`,
  `PROJECT_LOG.md`
- Stack harnesses: `minimal`, `python`, `node`, `go`
- `scripts/forge-adopt.sh` + `forge-adopt.ps1`
- `docs/ADOPT.md`, `KIT_LAYOUT.md`, `OPS_PER_REPO.md`, `CURSOR_RULES.md`
- `templates/cursor/forge-v3.mdc`
- `Forge/Patterns/README.md` + example pattern
- `Forge/Projects/_TEMPLATE_SLUG/00-Project-Index.md`
- `README.md`, `FORGE_MAINTAINER.md`

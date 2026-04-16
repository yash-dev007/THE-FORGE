# THE FORGE kit — changelog

Adopted repos track their own hypothesis history in `PROJECT_LOG.md`.
This file tracks **kit-level** revisions (templates, scripts, docs).

When `templates/universal/FORGE.md` is updated, bump its `Kit template revision:`
footer. Adopted repos should re-run `scripts/forge-update.*` to pull the latest
operating rules and platform bridge files.

---

## v4.0 — 2026-04-16

### Added
- `scripts/forge-cycle.sh` — Core loop driver: reads Quintet, runs EVAL × 3, computes
  median, anti-gaming anomaly check, decision (COMMIT/REVERT/HOLD), PROJECT_LOG.md write,
  Obsidian sync call. Supports `--baseline-only` and `--skip-baseline` modes.
- `scripts/forge-cycle.ps1` — PowerShell wrapper for Windows (delegates to forge-cycle.sh
  via auto-detected Git Bash).
- `scripts/forge-obsidian-sync.sh` — Writes cycle result to Obsidian vault: appends to
  `01-Score-History.md`, updates `00-Project-Index.md`, detects pattern candidates.
- `scripts/forge-obsidian-sync.ps1` — PowerShell equivalent.
- `scripts/forge-chart.py` — Zero-dependency score visualization: reads PROJECT_LOG.md,
  outputs `forge-chart.html` with line chart + table. Falls back to plotly if installed.
- `templates/claude-code/skills/forge-cycle.md` — `/forge-cycle` slash command for Claude Code.
- `templates/codex/program.md` — Codex bridge file (program.md convention, same 8-step gate).
- `templates/copilot/copilot-instructions.md` — GitHub Copilot workspace instructions.
- `templates/stacks/rust/` — Rust stack: EVAL.sh (cargo test + clippy + gocyclo +
  cargo bench/Criterion), EVAL_SPEC.md, `benches/forge_bench.rs` starter.
- `templates/stacks/python/benchmark.py` — pytest-benchmark starter fixture.
- `templates/stacks/node/benchmark.js` — vitest bench starter.
- `Forge/Projects/_TEMPLATE_SLUG/01-Score-History.md` — Score history Obsidian template.
- `Forge/Projects/_TEMPLATE_SLUG/02-Blocked-Approaches.md` — Blocked approaches template.
- `Forge/Patterns/` — 15 pre-seeded patterns across Python (5), Node (3), Go (3), Universal (4).
- `docs/LOOP_DRIVER.md` — How `forge-cycle.sh` works, modes, anti-gaming, exit codes.
- `docs/PLATFORMS.md` — Multi-platform guide: per-platform setup, `--platforms` flag,
  how to add a new platform.
- `docs/spec/CLAUDE_v4.md` — v4 methodology spec (v3 archived as `docs/spec/CLAUDE_v3.md`).

### Changed
- `scripts/forge-adopt.sh` — Added `--interactive` flag (fills templates, runs first EVAL),
  `--platforms` flag (select which platform bridge files to copy), Rust stack support,
  copies forge-cycle.sh + forge-obsidian-sync.sh + forge-chart.py to target.
- `scripts/forge-adopt.ps1` — Same as above; fixed garbled duplicate lines at end of file;
  added forge-chart.py copy to target.
- `scripts/forge-update.sh` — Fixed reference from deleted `CLAUDE.md` to `FORGE_BRIDGE.md`;
  now refreshes loop driver scripts and all platform bridge files; added rust to --stack.
- `scripts/forge-update.ps1` — Same fixes as forge-update.sh; added "rust" to -Stack ValidateSet.
- `templates/stacks/python/EVAL.sh` — Real PERF_SCORE via pytest-benchmark (replaces placeholder).
- `templates/stacks/node/EVAL.sh` — Real PERF_SCORE via vitest bench (replaces placeholder).
- `templates/stacks/go/EVAL.sh` — Real PERF_SCORE via go test -bench (replaces placeholder).
- `templates/gemini-cli/GEMINI.md` — Updated with forge-cycle.sh invocation steps.
- `Forge/Projects/_TEMPLATE_SLUG/00-Project-Index.md` — Updated to reference new template files.
- `docs/ADOPT.md` — Updated for v4: --interactive mode, --platforms flag, Rust stack,
  loop driver usage, forge-chart.py.
- `docs/KIT_LAYOUT.md` — Documented all v4 new files and directories.
- `README.md` — Version badge → v4.0; added Rust to stacks badge.
- `FORGE_MAINTAINER.md` — Work summary updated for v4.

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
- `templates/claude-code/FORGE_BRIDGE.md` — Claude Code bridge file for adopted repos
  (startup gate, Bash-based EVAL.sh runner, Obsidian file-read pattern)
- `templates/claude-code/settings.json` — example Claude Code hooks/settings
- `scripts/forge-update.sh` + `forge-update.ps1` — refresh templates in an
  already-adopted repo without overwriting project state
- `docs/EVAL_BENCHMARKS.md` — guide for wiring real PERF_SCORE benchmarks
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
- `templates/cursor/forge.mdc` (renamed from forge-v3.mdc)
- `Forge/Patterns/README.md` + example pattern
- `Forge/Projects/_TEMPLATE_SLUG/00-Project-Index.md`
- `README.md`, `FORGE_MAINTAINER.md`

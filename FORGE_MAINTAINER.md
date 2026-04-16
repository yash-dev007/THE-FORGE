# FORGE_MAINTAINER.md — THE FORGE kit (universal agent / maintainer notes)

This file documents **what this repository is**, **what was built**, and **how
AI agents should use it**. It is not part of the v3 Quintet that gets copied into
application repos; it is **kit-local** documentation for anyone opening THE FORGE
in an AI-powered editor or CLI.

---

## What this repo is

**THE FORGE** is a **multi-project methodology kit** derived from
[docs/spec/CLAUDE_v3.md](docs/spec/CLAUDE_v3.md). It does not ship one product's
application code. It ships:

- **Templates** so any target repository can adopt a per-repo **Quintet**
  (`CLAUDE.md`, `FORGE_IDENTITY.md`, `RESEARCH.md`, `EVAL_SPEC.md`, `EVAL.sh`,
  `FORGE_SYSTEM.md`, `PROJECT_LOG.md`).
- **Stack starters** for evaluation harnesses (`minimal`, `python`, `node`, `go`).
- **Agent integration** for various platforms (Cursor `.mdc` rules, Claude Code `.claude/`, Gemini CLI `GEMINI.md`).
- **Docs** for adoption, kit layout, EVAL customization, Obsidian setup, and ops.
- **Obsidian samples** under `Forge/` when this folder is used as (or mirrored into)
  a vault.

Canonical agent operating rules for **adopted** projects live in
[templates/universal/FORGE.md](templates/universal/FORGE.md)
(multi-project wording, `FORGE_IDENTITY.md`, Obsidian slug isolation).

AI workspace context for this kit repo lives in [CLAUDE.md](CLAUDE.md)
(the platform-neutral rule file for this repository).

---

## Work implemented (summary)

Refer to [README.md](README.md) for the high-level overview and [docs/KIT_LAYOUT.md](docs/KIT_LAYOUT.md) for the detailed file map.

### v4.0 — Self-running loop driver + full platform support
- **Loop driver:** `forge-cycle.sh` — one command runs the full Diagnose → Verify cycle.
  Handles EVAL × 3 median, anti-gaming anomaly detection, decision, PROJECT_LOG write.
- **Obsidian automation:** `forge-obsidian-sync.sh` — auto-writes Score History,
  updates Project Index, detects pattern promotion candidates.
- **Score visualization:** `forge-chart.py` — zero-dependency HTML chart from PROJECT_LOG.md.
- **Real PERF_SCORE:** pytest-benchmark (Python), vitest bench (Node), go test -bench (Go),
  cargo bench/Criterion (Rust). No more static 6.0 placeholder.
- **Rust stack:** Full EVAL harness for Rust (cargo test + clippy + cargo bench).
- **Interactive adoption:** `--interactive` flag fills templates and runs first EVAL in < 5 min.
- **Platform selection:** `--platforms` flag chooses which bridge files to copy.
- **Codex + Copilot:** First-class platform support added alongside Claude/Gemini/Cursor.
- **Pre-seeded patterns:** 15 patterns across Python (5), Node (3), Go (3), Universal (4).
- **New docs:** `docs/PLATFORMS.md` (multi-platform guide), `docs/spec/CLAUDE_v4.md` (v4 spec),
  `docs/LOOP_DRIVER.md` (loop driver reference).
- **Bug fixes:** `forge-adopt.ps1` garbled end, missing `forge-chart.py` copy;
  `forge-update.sh`/`.ps1` reference to deleted `CLAUDE.md` → `FORGE_BRIDGE.md`.

### v3.2 — Platform Neutrality & Gemini CLI
- Renamed `templates/universal/CLAUDE.md` to `FORGE.md`.
- Renamed `cursor.md` to `FORGE_MAINTAINER.md`.
- Added Gemini CLI support via `templates/gemini-cli/GEMINI.md`.
- Updated all scripts and docs to be agent-agnostic.

### v3.1 — Deep completion pass
- Added Claude Code bridge and settings.
- Implemented real DEBT_SCORE logic for Node and Go stacks.
- Expanded `FORGE_SYSTEM.md` template.
- Added guides for EVAL customization and Obsidian setup.

### v3.0 — Initial build
- Core multi-project kit structure.
- Universal Quintet templates.
- EVAL stack starters for Python, Node, Go, and Minimal.
- Adoption and update scripts.

---

## How AI agents should treat this workspace

1. **When editing THE FORGE (this repo):** You are maintaining **templates and docs**.
   Prefer small, focused edits; keep `templates/universal/FORGE.md` aligned with
   v3 semantics in `docs/spec/CLAUDE_v3.md` when the spec changes.

2. **When the user adopts Forge elsewhere:** They copy files from `templates/` (or
   run `scripts/forge-adopt.*`). The **active** `CLAUDE.md`, Quintet, and
   bridge files live in the **target** repo root, not here.

3. **Obsidian:** Paths in v3 assume `Forge/Patterns/` (global) and
   `Forge/Projects/<ForgeProjectSlug>/` (one folder per adopted repo). Slug is
   **not** the same as the folder name on disk unless chosen that way — see
   [docs/KIT_LAYOUT.md](docs/KIT_LAYOUT.md).

---

## Quick commands

```powershell
# Windows: adopt into another repo
.\scripts\forge-adopt.ps1 -TargetRepo 'D:\path\to\app' -Stack python

# Windows: update an already-adopted repo
.\scripts\forge-update.ps1 -TargetRepo 'D:\path\to\app'
```

```bash
# Unix / Git Bash: adopt
./scripts/forge-adopt.sh --target /path/to/app --stack go

# Unix / Git Bash: update
./scripts/forge-update.sh --target /path/to/app
```

After adoption: edit `FORGE_IDENTITY.md`, fill `RESEARCH.md` / `FORGE_SYSTEM.md`,
run `bash ./EVAL.sh` three times for baseline (see [docs/ADOPT.md](docs/ADOPT.md)).

---

## Repository Map

Refer to **[docs/KIT_LAYOUT.md](docs/KIT_LAYOUT.md)** for a complete directory map and file roles.

---

## Changelog (kit workspace)

- **2026-04-16 v4.0** — Self-running loop driver, Obsidian automation, real PERF_SCORE
  per stack, Rust stack, interactive adoption, Codex + Copilot platforms, pre-seeded
  pattern library, score visualization, PLATFORMS.md + CLAUDE_v4.md spec.
- **2026-04-13 v3.2** — Gemini CLI support added to all stacks and adoption scripts.
- **2026-04-12 v3.1** — Deep completion: Claude Code integration, DEBT_SCORE fixes
  for Node + Go, FORGE_SYSTEM template expansion, ADOPT.md Claude Code section,
  EVAL_BENCHMARKS guide, OBSIDIAN_SETUP guide, forge-update scripts.
- **2026-04-12 v3.0** — Initial multi-project kit: templates, stacks, docs, scripts,
  Obsidian samples, Cursor rule template.

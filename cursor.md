# cursor.md — THE FORGE kit (agent / maintainer notes)

This file documents **what this repository is**, **what was built**, and **how
Cursor should use it**. It is not part of the v3 Quintet that gets copied into
application repos; it is **kit-local** documentation for anyone opening THE FORGE
in Cursor.

---

## What this repo is

**THE FORGE** is a **multi-project methodology kit** derived from
[temp_docs/CLAUDE_v3.md](temp_docs/CLAUDE_v3.md). It does not ship one product's
application code. It ships:

- **Templates** so any target repository can adopt a per-repo **Quintet**
  (`CLAUDE.md`, `FORGE_IDENTITY.md`, `RESEARCH.md`, `EVAL_SPEC.md`, `EVAL.sh`,
  `FORGE_SYSTEM.md`, `PROJECT_LOG.md`).
- **Stack starters** for evaluation harnesses (`minimal`, `python`, `node`, `go`).
- **Agent integration** for both Cursor (`.mdc` rule) and Claude Code (`.claude/`).
- **Docs** for adoption, kit layout, EVAL customization, Obsidian setup, and ops.
- **Obsidian samples** under `Forge/` when this folder is used as (or mirrored into)
  a vault.

Canonical agent operating rules for **adopted** projects live in
[templates/universal/CLAUDE.md](templates/universal/CLAUDE.md)
(multi-project wording, `FORGE_IDENTITY.md`, Obsidian slug isolation).

Claude Code workspace context for this kit repo lives in [CLAUDE.md](CLAUDE.md)
(do not confuse with the template).

---

## Work implemented (summary)

### v3.0 — initial Cursor build

| Area | Deliverable |
|------|-------------|
| Layout | [docs/KIT_LAYOUT.md](docs/KIT_LAYOUT.md) — directory map, `ForgeProjectSlug` rules |
| Universal v3 | [templates/universal/CLAUDE.md](templates/universal/CLAUDE.md) — v3 rules + identity/slug |
| Identity | [templates/universal/FORGE_IDENTITY.md.template](templates/universal/FORGE_IDENTITY.md.template) |
| Quintet templates | `RESEARCH.md.template`, `FORGE_SYSTEM.md.template`, `PROJECT_LOG.md.template` |
| EVAL stacks | `minimal`, `python`, `node`, `go` — each with `EVAL_SPEC.md` + `EVAL.sh` |
| Adoption | [docs/ADOPT.md](docs/ADOPT.md) — repeatable playbook for any repo |
| Cursor | [templates/cursor/forge-v3.mdc](templates/cursor/forge-v3.mdc) + [docs/CURSOR_RULES.md](docs/CURSOR_RULES.md) |
| Ops | [docs/OPS_PER_REPO.md](docs/OPS_PER_REPO.md) — Auditor / distillation / stagnation scoped per log |
| Scripts | [scripts/forge-adopt.ps1](scripts/forge-adopt.ps1) + [scripts/forge-adopt.sh](scripts/forge-adopt.sh) |
| Obsidian | [Forge/Patterns/](Forge/Patterns/) (README + example), [Forge/Projects/_TEMPLATE_SLUG/](Forge/Projects/_TEMPLATE_SLUG/) |
| Entry | [README.md](README.md) — overview and links |

**Verified:** `templates/stacks/minimal/EVAL.sh` runs under Git Bash on Windows.

### v3.1 — deep completion pass

| Area | Deliverable |
|------|-------------|
| Kit CLAUDE.md | [CLAUDE.md](CLAUDE.md) — Claude Code workspace context (kit repo, not an adopted project) |
| Claude Code integration | [templates/claude-code/CLAUDE.md](templates/claude-code/CLAUDE.md) — startup gate, Bash EVAL runner, Obsidian read pattern |
| Claude Code settings | [templates/claude-code/settings.json](templates/claude-code/settings.json) — example hooks |
| DEBT_SCORE — Node | [templates/stacks/node/EVAL.sh](templates/stacks/node/EVAL.sh) — ESLint complexity rule (CC > 10); no longer static |
| DEBT_SCORE — Go | [templates/stacks/go/EVAL.sh](templates/stacks/go/EVAL.sh) — gocyclo -over 10; no longer static |
| PERF comments | All three real EVAL.sh starters annotated with benchmark wiring instructions |
| Node EVAL_SPEC | [templates/stacks/node/EVAL_SPEC.md](templates/stacks/node/EVAL_SPEC.md) — documents ESLint complexity tool + table |
| Go EVAL_SPEC | [templates/stacks/go/EVAL_SPEC.md](templates/stacks/go/EVAL_SPEC.md) — documents gocyclo + DEBT interpretation table |
| FORGE_SYSTEM template | [templates/universal/FORGE_SYSTEM.md.template](templates/universal/FORGE_SYSTEM.md.template) — 6 structured sections aligned with Auditor Protocol questions |
| ADOPT.md | [docs/ADOPT.md](docs/ADOPT.md) — Step 7b (Claude Code), Step 8 (Obsidian), forge-update, versioning |
| CUSTOMIZING_EVAL | [docs/CUSTOMIZING_EVAL.md](docs/CUSTOMIZING_EVAL.md) — PERF wiring per stack + calibration guide |
| OBSIDIAN_SETUP | [docs/OBSIDIAN_SETUP.md](docs/OBSIDIAN_SETUP.md) — 3 vault modes, Claude Code file-read pattern, promotion workflow |
| forge-update | [scripts/forge-update.sh](scripts/forge-update.sh) + [scripts/forge-update.ps1](scripts/forge-update.ps1) — refresh already-adopted repos |
| forge-adopt | Updated adopt scripts copy `.claude/` automatically |
| CHANGELOG | [docs/CHANGELOG.md](docs/CHANGELOG.md) — v3.0 and v3.1 entries |

---

## How Cursor should treat this workspace

1. **When editing THE FORGE (this repo):** You are maintaining **templates and docs**.
   Prefer small, focused edits; keep `templates/universal/CLAUDE.md` aligned with
   v3 semantics in `temp_docs/CLAUDE_v3.md` when the spec changes.

2. **When the user adopts Forge elsewhere:** They copy files from `templates/` (or
   run `scripts/forge-adopt.*`). The **active** `CLAUDE.md`, Quintet, and
   `.claude/CLAUDE.md` live in the **target** repo root, not here.

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

## Related files (do not confuse)

| File | Role |
|------|------|
| [temp_docs/CLAUDE_v3.md](temp_docs/CLAUDE_v3.md) | Original v3 spec snapshot (reference) |
| [templates/universal/CLAUDE.md](templates/universal/CLAUDE.md) | Canonical **copy** for adopted repos |
| [templates/claude-code/CLAUDE.md](templates/claude-code/CLAUDE.md) | Claude Code bridge for adopted repos |
| [CLAUDE.md](CLAUDE.md) | Kit workspace context for Claude Code (not for adopted repos) |
| [cursor.md](cursor.md) | **This file** — kit workspace notes for Cursor |

---

## Changelog (kit workspace)

- **2026-04-12 v3.1** — Deep completion: Claude Code integration, DEBT_SCORE fixes
  for Node + Go, FORGE_SYSTEM template expansion, ADOPT.md Claude Code section,
  CUSTOMIZING_EVAL guide, OBSIDIAN_SETUP guide, forge-update scripts.
- **2026-04-12 v3.0** — Initial multi-project kit: templates, stacks, docs, scripts,
  Obsidian samples, Cursor rule template.

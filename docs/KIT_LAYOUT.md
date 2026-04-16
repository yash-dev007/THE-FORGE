# THE FORGE kit — directory layout

This repository is a **portable methodology kit**. It does not assume a single
application. Each real codebase **adopts** copies of the Quintet + stack `EVAL.*`
from here into **that repository's root** (see [ADOPT.md](ADOPT.md)).

---

## Top-level tree

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Universal Forge operating rules (copied from `templates/universal/FORGE.md`) |
| `FORGE_MAINTAINER.md` | Universal agent and maintainer notes for the kit repo |
| `README.md` | Human-facing overview and quick links |
| `docs/spec/CLAUDE_v3.md` | Archived source spec (v3.0); canonical living text is `templates/universal/FORGE.md` |
| `docs/ADOPT.md` | Adoption playbook for any project |
| `docs/KIT_LAYOUT.md` | This file |
| `docs/CURSOR_RULES.md` | User-level vs per-repo Cursor integration |
| `docs/OPS_PER_REPO.md` | Per-repository counters (Auditor, cycles, stagnation) |
| `docs/EVAL_BENCHMARKS.md` | How to wire real PERF_SCORE benchmarks per stack |
| `docs/OBSIDIAN_SETUP.md` | Vault setup, co-location options, Claude Code read pattern |
| `docs/LOOP_DRIVER.md` | forge-cycle.sh documentation: modes, anti-gaming, exit codes |
| `docs/PLATFORMS.md` | Multi-platform guide: per-platform setup, --platforms flag |
| `docs/CHANGELOG.md` | Kit revision history (methodology + harness changes) |
| `docs/spec/CLAUDE_v3.md` | Archived v3 spec |
| `docs/spec/CLAUDE_v4.md` | Current v4 spec (canonical reference) |
| `templates/universal/` | Project-agnostic Quintet templates (CLAUDE.md + 4 Quintet templates) |
| `templates/stacks/<stack>/` | Starter `EVAL_SPEC.md` + `EVAL.sh` per stack |
| `templates/cursor/forge.mdc` | Cursor rule to copy into adopted repos |
| `templates/claude-code/FORGE_BRIDGE.md` | Claude Code bridge file copied to `<repo>/.claude/CLAUDE.md` |
| `templates/claude-code/settings.json` | Example Claude Code hooks/settings for adopted repos |
| `scripts/forge-adopt.ps1` | Windows: copy all templates into a new target repo |
| `scripts/forge-adopt.sh` | Unix: copy all templates into a new target repo |
| `scripts/forge-update.ps1` | Windows: refresh methodology files in an already-adopted repo |
| `scripts/forge-update.sh` | Unix: refresh methodology files in an already-adopted repo |
| `scripts/forge-cycle.sh` | Unix: loop driver core (EVAL × 3, decision, log write, Obsidian sync) |
| `scripts/forge-cycle.ps1` | Windows: PowerShell wrapper (delegates to forge-cycle.sh via Git Bash) |
| `scripts/forge-obsidian-sync.sh` | Unix: Obsidian write helper (Score History + Project Index + pattern detection) |
| `scripts/forge-obsidian-sync.ps1` | Windows: PowerShell equivalent |
| `scripts/forge-chart.py` | Score visualization: reads PROJECT_LOG.md, outputs forge-chart.html |
| `Forge/Patterns/` | Obsidian: **global** patterns (optional vault co-located with kit) |
| `Forge/Projects/` | Obsidian: one subfolder per adopted **project slug** |

---

## Template subdirectories

### `templates/universal/`

| File | Copied to adopted repo as |
|------|--------------------------|
| `FORGE.md` | `CLAUDE.md` (Operating Rules) |
| `FORGE_IDENTITY.md.template` | `FORGE_IDENTITY.md` (fill YAML after copy) |
| `RESEARCH.md.template` | `RESEARCH.md` (fill hypothesis fields) |
| `FORGE_SYSTEM.md.template` | `FORGE_SYSTEM.md` (fill all six sections) |
| `PROJECT_LOG.md.template` | `PROJECT_LOG.md` (cycle history starts here) |

### `templates/stacks/`

Each stack directory contains:

| File | Purpose |
|------|---------|
| `EVAL_SPEC.md` | Scorecard dimensions, weights, tool descriptions |
| `EVAL.sh` | Executable harness producing the 5 score lines |
| `benchmark.*` | Starter benchmark fixture (python/node only) |
| `benches/` | Criterion bench starter (rust only) |

Available stacks:

| Stack | TEST | QUAL | DEBT | PERF |
|-------|------|------|------|------|
| `minimal` | noop 5.0 | noop 5.0 | noop 5.0 | noop 5.0 |
| `python` | pytest | ruff | radon CC | pytest-benchmark |
| `node` | npm test | eslint | eslint complexity | vitest bench |
| `go` | go test | golangci-lint | gocyclo | go test -bench |
| `rust` | cargo test | clippy | cargo-geiger | cargo bench (Criterion) |

### `templates/claude-code/`

| File | Copied to adopted repo as |
|------|--------------------------|
| `FORGE_BRIDGE.md` | `.claude/CLAUDE.md` |
| `settings.json` | `.claude/settings.json` (only if not already present) |
| `skills/forge-cycle.md` | `.claude/skills/forge-cycle.md` (`/forge-cycle` skill) |

### `templates/cursor/`

| File | Copied to adopted repo as |
|------|--------------------------|
| `forge.mdc` | `.cursor/rules/forge.mdc` |

### `templates/codex/`

| File | Copied to adopted repo as |
|------|--------------------------|
| `program.md` | `program.md` |

### `templates/copilot/`

| File | Copied to adopted repo as |
|------|--------------------------|
| `copilot-instructions.md` | `.github/copilot-instructions.md` |

---

## Obsidian project slug rules

Slugs must be **stable** and **unique** across all projects sharing the vault.

1. **Preferred:** `<github_org>-<repo_name>` in lowercase with hyphens,
   e.g. `acme-api-gateway`.
2. **If collision:** append a short disambiguator, e.g. `acme-api-gateway-v2` or
   `acme-api-gateway-a3f9` (use `git rev-parse --short HEAD` once at adopt time).
3. Record the slug in the target repo's `FORGE_IDENTITY.md` (field `ForgeProjectSlug`).
   Every agent session resolves the Obsidian path as `Forge/Projects/<ForgeProjectSlug>/`.

Never reuse another project's slug. Never query another project's folder in a session.

---

## Target repository after adoption

Each adopted repo contains at its **root**:

```
CLAUDE.md            ← operating rules (from templates/universal/FORGE.md)
GEMINI.md            ← Gemini CLI startup gate + EVAL runner + Obsidian access
FORGE_IDENTITY.md    ← project name, stack, Obsidian slug, vault hint
RESEARCH.md          ← active hypothesis (strict schema — 8 required fields)
EVAL_SPEC.md         ← scorecard (from chosen templates/stacks/<stack>/)
EVAL.sh              ← evaluation harness (from chosen templates/stacks/<stack>/)
FORGE_SYSTEM.md      ← architecture — fill all six sections
PROJECT_LOG.md       ← cycles and velocity for this repo only

.claude/
  CLAUDE.md          ← Claude Code startup gate + EVAL runner + Obsidian access
  settings.json      ← example hooks (edit to taste)

.cursor/rules/
  forge.mdc       ← Cursor rule
```

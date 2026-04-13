# THE FORGE — kit workspace (Gemini CLI context)

> **This is the methodology KIT repository — not an adopted project.**
> The v3 research loop runs in repos that ADOPT Forge, not here.

## What this repository is

THE FORGE is a **portable Research Engineer workflow kit**. It ships templates,
EVAL harnesses, adoption scripts, and Obsidian vault structure that any repository
can adopt. There is no active hypothesis running in this repository.

`templates/universal/FORGE.md` and other template files are **template artifacts** — do not read them as
your operating context for this session.

---

## Rules for Gemini CLI sessions in this repo

### Absolute constraints

1. **Never run the v3 research loop** (Diagnose → Hypothesize → Execute → Verify → Synthesize) on this repo's own files.
2. **Never execute `EVAL.sh`** — there is none at the kit root. Stack `EVAL.sh` files under `templates/stacks/` are templates to inspect, improve, and test, not to run against this repo.
3. **Never treat `templates/universal/FORGE.md` or any `.md.template` as active operating rules.** They are text artifacts copied into adopting repos.
4. **Never create `RESEARCH.md`, `EVAL_SPEC.md`, `FORGE_SYSTEM.md`, `FORGE_IDENTITY.md`, or `PROJECT_LOG.md` at this root.** Those are per-adopted-repo state files.

### What you ARE doing here

You are a **kit maintainer**. Your tasks:
- Editing or improving files under `templates/`, `scripts/`, `docs/`, or `Forge/`
- Keeping `templates/universal/FORGE.md` and other templates aligned with `temp_docs/CLAUDE_v3.md`
- Improving stack EVAL harnesses for correctness and completeness
- Updating adoption docs and automation scripts

---

## File roles (do not confuse these)

| File | Role |
|------|------|
| `temp_docs/CLAUDE_v3.md` | Original v3 spec snapshot — canonical source of truth |
| `templates/universal/FORGE.md` | Living copy for adopted repos (keep aligned with v3) |
| `templates/stacks/*/EVAL.sh` | Starter harnesses — review and improve, do not run here |
| `scripts/forge-adopt.*` | Adoption scripts — test logic, do not adopt THIS repo |
| `scripts/forge-update.*` | Template-refresh scripts for already-adopted repos |
| `Forge/Patterns/` | Global Obsidian pattern notes (read/write as vault notes) |
| `Forge/Projects/_TEMPLATE_SLUG/` | Obsidian project folder template — copy on adoption |
| `CLAUDE.md` | universal kit workspace rules |
| `FORGE_MAINTAINER.md` | Kit workspace notes |
| `GEMINI.md` | **This file** — Gemini CLI workspace context |

---

## Consistency rule for template edits

When editing templates, verify alignment with canonical documentation:
- All 8 required RESEARCH.md fields must be preserved.
- Anti-gaming rules must be verbatim or stricter.
- Maintain placeholder structure for easy adoption by any tech stack.

---

## Obsidian co-location

If `.obsidian/` exists in this repository root, this folder IS the shared vault.
- `Forge/Patterns/` — global cross-project patterns (read/write)
- `Forge/Projects/_TEMPLATE_SLUG/` — template only; copy-rename on adoption
- Do NOT create `Forge/Projects/<real-slug>/` here unless this repo is the designated shared vault and that project has been formally adopted.

---

## Agent Behavior in Kit Development

When working on the kit itself, follow these principles:
- **No Hypotheses:** Don't attempt to score changes or write hypotheses for changes to the kit.
- **Maintain Template Integrity:** When editing templates, ensure they maintain their placeholder variables and generic structure.
- **Update Documentation:** When modifying scripts or directory structures, always check and update the relevant markdown files in `docs/`.

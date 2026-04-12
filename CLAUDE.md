# THE FORGE — kit workspace (Claude Code context)
> **This is the methodology KIT repository — not an adopted project.**
> The v3 research loop runs in repos that ADOPT Forge, not here.

## What this repository is

THE FORGE is a **portable Research Engineer workflow kit**. It ships templates,
EVAL harnesses, adoption scripts, and Obsidian vault structure that any repository
can adopt. There is no active hypothesis running in this repository.

`templates/universal/CLAUDE.md` is a **template artifact** — do not read it as
your operating context for this session.

---

## Rules for Claude Code sessions in this repo

### Absolute constraints

1. **Never run the v3 research loop** (Diagnose → Hypothesize → Execute → Verify →
   Synthesize) on this repo's own files.
2. **Never execute `EVAL.sh`** — there is none at the kit root. Stack `EVAL.sh`
   files under `templates/stacks/` are templates to inspect, improve, and test,
   not to run against this repo.
3. **Never treat `templates/universal/CLAUDE.md` as active operating rules.** It is
   a text artifact copied into adopting repos.
4. **Never create `RESEARCH.md`, `EVAL_SPEC.md`, or `PROJECT_LOG.md` at this root.**
   Those are per-adopted-repo state files.

### What you ARE doing here

You are a **kit maintainer**. Your tasks:
- Editing or improving files under `templates/`, `scripts/`, `docs/`, or `Forge/`
- Keeping `templates/universal/CLAUDE.md` aligned with `temp_docs/CLAUDE_v3.md`
- Improving stack EVAL harnesses for correctness and completeness
- Updating adoption docs and automation scripts

---

## File roles (do not confuse these)

| File | Role |
|------|------|
| `temp_docs/CLAUDE_v3.md` | Original v3 spec snapshot — canonical source of truth |
| `templates/universal/CLAUDE.md` | Living copy for adopted repos (keep aligned with v3) |
| `templates/stacks/*/EVAL.sh` | Starter harnesses — review and improve, do not run here |
| `templates/claude-code/CLAUDE.md` | Claude Code bridge copied into `.claude/` of adopted repos |
| `templates/cursor/forge-v3.mdc` | Cursor rule copied into `.cursor/rules/` of adopted repos |
| `scripts/forge-adopt.*` | Adoption scripts — test logic, do not adopt THIS repo |
| `scripts/forge-update.*` | Template-refresh scripts for already-adopted repos |
| `Forge/Patterns/` | Global Obsidian pattern notes (read/write as vault notes) |
| `Forge/Projects/_TEMPLATE_SLUG/` | Obsidian project folder template — copy on adoption |
| `cursor.md` | Cursor workspace notes (what was built, how Cursor should use this repo) |
| `CLAUDE.md` | **This file** — Claude Code workspace context |

---

## Consistency rule for template edits

When editing `templates/universal/CLAUDE.md`, verify alignment with
`temp_docs/CLAUDE_v3.md`:

- All 8 required RESEARCH.md fields must be preserved
- The Evolution Loop diagram must match the spec
- Anti-gaming rules must be verbatim or stricter
- Initialization sequence step count must not change
- Multi-project additions (ForgeProjectSlug, FORGE_IDENTITY.md) must not contradict v3

After any substantive edit, bump the `Kit template revision:` footer line in
`templates/universal/CLAUDE.md`.

---

## Obsidian co-location

If `.obsidian/` exists in this repository root, this folder IS the shared vault.
- `Forge/Patterns/` — global cross-project patterns (read/write)
- `Forge/Projects/_TEMPLATE_SLUG/` — template only; copy-rename on adoption
- Do NOT create `Forge/Projects/<real-slug>/` here unless this repo is the
  designated shared vault and that project has been formally adopted.

---

## Kit version

Current: **v3.1** (2026-04-12)
See `docs/CHANGELOG.md` for revision history.

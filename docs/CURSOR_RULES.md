# Cursor rules for THE FORGE (all projects)

## Goal

The same agent behavior should apply **whichever repository** you open, as long as that repo has adopted Forge (Quintet + `EVAL.sh` at root).

## Option A — Per-repository rule (recommended default)

After adoption, the repo contains `.cursor/rules/forge-v3.mdc` (copied by `forge-adopt` scripts or manually from `templates/cursor/forge-v3.mdc`).

- Scoped to that codebase only.
- Travels with the repo for teammates.

Set `alwaysApply: true` in the frontmatter of `forge-v3.mdc` if you want it active without globs; leave `false` if you prefer enabling via Cursor UI for Forge-heavy weeks.

## Option B — User-level rule

Copy the body of `templates/cursor/forge-v3.mdc` into your **user** Cursor rules (or merge into an existing user rule file).

- Applies to **every** workspace; the rule text gates on presence of `RESEARCH.md` + `EVAL_SPEC.md` + `EVAL.sh` so non-Forge repos are mostly unaffected.
- Risk: stricter global context use; keep the rule concise.

## Behavior summary (either option)

1. Read Quintet from **current repository root**.
2. Respect `FORGE_IDENTITY.md` → Obsidian slug isolation.
3. Three-run median for `EVAL.sh`; status line on messages; no agent edits to `EVAL.sh` / `EVAL_SPEC.md` during cycles.

See [ADOPT.md](ADOPT.md) step 6 for install order.

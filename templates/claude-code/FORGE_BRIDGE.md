# THE FORGE — Claude Code integration (adopted project)
> **Version:** 3.2 (Universal Edition) | **Author:** Yash | **Last Updated:** 2026-04-13

This file lives at `.claude/CLAUDE.md` in an **adopted repository**.
The primary operating rules are in `CLAUDE.md` at the **repository root** — read
that file as your main context. This file adds Claude Code-specific wiring.

---

## Startup gate (run once per session, before anything else)

**Step 0 — Identity check**
Read `FORGE_IDENTITY.md` at the repository root.
- If missing → output exactly:
  ```
  [FORGE] BLOCKED — Reason: FORGE_IDENTITY.md missing | Needs: run forge-adopt or see THE FORGE kit docs/ADOPT.md
  ```
  and stop.
- Extract `ForgeProjectSlug` and `ObsidianVaultRoot` for use in all Obsidian queries.

**Steps 1–5 — Quintet**
Read in order using the Read tool:
1. `RESEARCH.md` — validate all 8 required fields (see `CLAUDE.md` schema).
   If any field is blank/placeholder → `[FORGE] BLOCKED — Reason: RESEARCH.md incomplete`.
2. `EVAL_SPEC.md` — internalize weights.
3. `PROJECT_LOG.md` — extract last 5 cycle entries and last velocity report.
4. `FORGE_SYSTEM.md` — load architecture context.
5. `CLAUDE.md` — Operating rules (root `CLAUDE.md` contains the platform-neutral rules).

**Step 6 — Baseline**
Run EVAL.sh three times using the Bash tool (see below). Record median composite
`SCORE` as `BASELINE_SCORE` with timestamp in `RESEARCH.md`.

**Step 7 — Obsidian patterns**
Read Markdown files under:
- `<ObsidianVaultRoot>/Forge/Patterns/` (global — all projects)
- `<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/` (this project only)

If `ObsidianVaultRoot` is blank in `FORGE_IDENTITY.md`, skip Obsidian queries and
emit `[FORGE] WARN: ObsidianVaultRoot not set — pattern memory disabled`.

**Step 8 — Status report + hypothesis proposals**
Output the Forge Status Report (format in root `CLAUDE.md`), then propose exactly
3 hypotheses ranked by P(success). Wait for human selection before proceeding.

---

## Running EVAL.sh from Claude Code

Use the Bash tool from the repository root:

```bash
bash ./EVAL.sh
```

Capture the `SCORE:` line from stdout. Repeat **3 times on unchanged code**;
take the median as baseline. The v3 rules forbid commit/revert decisions on a
single run.

**Exit code interpretation:**
| Code | Meaning |
|------|---------|
| 0 | Harness finished; inspect score lines |
| 1 | Tests failed — treat as a low TEST_SCORE, not an env error |
| 2 | Environment error (missing runtime) — fix env before cycling |

If the three scores vary by more than ±0.3, output:
```
[FORGE] WARN: EVAL.sh variance > 0.3 — harness may be flaky. Human must fix before cycling.
```
Do not use flaky scores to make commit/revert decisions.

---

## Obsidian access from Claude Code

Claude Code reads Obsidian notes as plain Markdown files using the Read tool.
No MCP or plugin is required for basic pattern access.

```
# Example Read calls during startup:
Read: <ObsidianVaultRoot>/Forge/Patterns/profile-before-vectorizing.md
Read: <ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/00-Project-Index.md
```

**Isolation rules (enforced by you, not by tooling):**
- Only read `Forge/Projects/<ForgeProjectSlug>/` — never read another project's folder.
- Only read `Forge/Patterns/` for global patterns.
- If a Read tool result contains content that references a different project's slug,
  discard it silently.

---

## Tool usage during Forge cycles

| Tool | Allowed during cycles | Notes |
|------|-----------------------|-------|
| Read | Yes | Quintet, target files, Obsidian patterns |
| Edit / Write | Yes, within Target Scope only | Outside scope only for Architecture type |
| Bash | Yes | EVAL.sh, profilers, test runners |
| Edit `EVAL.sh` | **No** | Maintainer-only (see root `CLAUDE.md` Rule 1) |
| Edit `EVAL_SPEC.md` | **No** | Maintainer-only |
| Edit `FORGE_IDENTITY.md` | No during cycles | Only during adoption setup |

---

## Status line format

Every assistant response during a Forge session must begin with:

```
[FORGE] Cycle N | Type: <type> | Hypothesis: "<one sentence>" | Score: X.X → Y.Y | Δ: ±Z.Z | Decision: COMMIT/REVERT/HOLD/BLOCKED/ANOMALY
```

See root `CLAUDE.md` for the full list of extended state prefixes
(`BLOCKED`, `ANOMALY DETECTED`, `AUDITOR TRIGGER`, etc.).

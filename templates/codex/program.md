# THE FORGE — Codex integration (adopted project)
> **Version:** 4.0 | **Author:** Yash | **Last Updated:** 2026-04-16

This file lives at `program.md` in an **adopted repository**.
The primary operating rules are in `CLAUDE.md` at the **repository root**.

---

## Startup gate (run once per session)

**Step 0 — Identity check**
Read `FORGE_IDENTITY.md` at the repository root.
- If missing → output exactly:
  ```
  [FORGE] BLOCKED — Reason: FORGE_IDENTITY.md missing | Needs: run forge-adopt or see THE FORGE kit docs/ADOPT.md
  ```
  and stop.
- Extract `ForgeProjectSlug` and `ObsidianVaultRoot`.

**Steps 1–5 — Quintet**
Read in order:
1. `RESEARCH.md` — validate all 8 required fields. If blank/placeholder → `[FORGE] BLOCKED`.
2. `EVAL_SPEC.md` — internalize weights.
3. `PROJECT_LOG.md` — last 5 cycle entries and velocity.
4. `FORGE_SYSTEM.md` — architecture context.
5. `CLAUDE.md` — operating rules.

**Step 6 — Baseline**
Run baseline using the shell tool:
```bash
bash ./forge-cycle.sh --baseline-only
```
Record the median COMPOSITE score as `BASELINE_SCORE`.

**Step 7 — Obsidian patterns**
Read Markdown files under:
- `<ObsidianVaultRoot>/Forge/Patterns/`
- `<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/`

**Step 8 — Status + hypotheses**
Output the Forge Status Report (format in root `CLAUDE.md`), then propose exactly 3 hypotheses ranked by P(success). Wait for human selection.

---

## Running the cycle

After human implements a hypothesis:
```bash
bash ./forge-cycle.sh --skip-baseline <BASELINE_SCORE>
```

The script handles 3-run median, anti-gaming checks, decision, PROJECT_LOG.md write, and Obsidian sync.

**Exit code interpretation:**
| Code | Meaning |
|------|---------|
| 0 | Harness finished; read decision from stdout |
| 1 | Tests failed — low TEST_SCORE, not env error |
| 2 | Environment error — fix before cycling |

---

## Tool usage during cycles

| Tool | Allowed | Notes |
|------|---------|-------|
| Read files | Yes | Quintet, targets, Obsidian patterns |
| Write / edit files | Yes, within Target Scope | Outside scope only for Architecture type |
| Shell commands | Yes | EVAL.sh, profilers, test runners |
| Edit `EVAL.sh` | **No** | Maintainer-only |
| Edit `EVAL_SPEC.md` | **No** | Maintainer-only |

---

## Status line format

Every response during a Forge session must begin with:
```
[FORGE] Cycle N | Type: <type> | Hypothesis: "<one sentence>" | Score: X.X → Y.Y | Δ: ±Z.Z | Decision: COMMIT/REVERT/HOLD/BLOCKED/ANOMALY
```

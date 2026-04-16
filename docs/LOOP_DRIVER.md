# THE FORGE — Loop Driver (`forge-cycle.sh`)

The loop driver is the core of THE FORGE v4. It replaces the manual "run EVAL three times, eyeball the numbers" workflow with a single command that handles the full cycle automatically.

## What it does

```
1. Read FORGE_IDENTITY.md  — extract ForgeProjectSlug
2. Read RESEARCH.md         — validate all 8 required fields
3. Run EVAL.sh × 3          — compute median baseline SCORE + sub-scores
4. Print Forge Status Report
5. [WAIT] Human implements hypothesis (or AI platform generates + human selects)
6. Run EVAL.sh × 3          — compute median post-implementation SCORE
7. Anti-gaming check        — flag anomalous sub-score jumps (Δ > 3.0 in any dimension)
8. Decision                 — COMMIT / REVERT / HOLD / ANOMALY
9. Write cycle entry        — append to PROJECT_LOG.md
10. Obsidian sync           — call forge-obsidian-sync.sh if ObsidianVaultRoot is set
11. Print next action
```

## Installation

`forge-adopt.sh` copies `forge-cycle.sh` and `forge-obsidian-sync.sh` to your adopted repo root automatically.

## Usage

```bash
# Full interactive cycle (pause at step 5 for human implementation)
bash ./forge-cycle.sh

# Baseline only (used by AI platforms before generating hypotheses)
bash ./forge-cycle.sh --baseline-only

# Evaluate after human implements (skip re-running baseline)
bash ./forge-cycle.sh --skip-baseline 6.50
```

On Windows (PowerShell):
```powershell
.\forge-cycle.ps1
.\forge-cycle.ps1 -BaselineOnly
.\forge-cycle.ps1 -SkipBaseline 6.50
```

## Typical AI platform workflow

AI platforms (Claude Code, Gemini, Cursor, Codex, Copilot) use the driver like this:

```
AI:    bash ./forge-cycle.sh --baseline-only   # step 1-4
AI:    Proposes 3 hypotheses ranked by P(success)
Human: Selects and implements one
AI:    bash ./forge-cycle.sh --skip-baseline 6.50  # step 6-11
AI:    Reports decision
```

The AI handles hypothesis generation and explanation. The script handles measurement, decisions, and logging.

## Anti-gaming rules

If any sub-score jumps by more than **±3.0** in a single cycle, the script outputs `[FORGE] ANOMALY DETECTED` and recommends reverting. This catches:
- Tests added without real implementation improvement (TEST_SCORE spike)
- Benchmarks gamed to show false PERF gains
- Linting silenced artificially (QUAL spike with no real cleanup)

The human must investigate before cycling continues.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Cycle complete (COMMIT, REVERT, or HOLD) |
| 1 | EVAL.sh reported test failure (examine score) |
| 2 | Environment error — fix env before cycling |

## Variance warning

If the three EVAL.sh runs vary by more than ±0.3, the script emits:
```
[FORGE] WARN: EVAL.sh variance > 0.3 — harness may be flaky
```
It does NOT stop — it reports and continues. The human must fix the harness before trusting results.

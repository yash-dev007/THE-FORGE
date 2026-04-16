---
name: forge-cycle
description: Run a full THE FORGE research cycle — baseline, hypothesis selection, implementation, evaluation, and decision
---

# /forge-cycle — THE FORGE v4 Loop Driver

This skill orchestrates a complete Forge research cycle in Claude Code.

## Step 1 — Run baseline

Use the Bash tool to run the baseline:

```bash
bash ./forge-cycle.sh --baseline-only
```

Capture the output. Extract:
- `COMPOSITE=X.XX` baseline score
- `PERF`, `QUAL`, `TEST`, `DEBT` sub-scores
- Any WARN messages about harness variance

If the script exits with code 2 (environment error), stop and tell the user to fix the environment.

## Step 2 — Load Obsidian context

Read the following files (use the Read tool):
1. `<ObsidianVaultRoot>/Forge/Patterns/` — scan pattern files for relevant mechanisms
2. `<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/00-Project-Index.md`
3. `<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/01-Score-History.md` (if it exists)

If `ObsidianVaultRoot` is blank, skip and emit:
```
[FORGE] WARN: ObsidianVaultRoot not set — pattern memory disabled
```

## Step 3 — Propose 3 hypotheses

Based on:
- The baseline sub-scores (which is weakest?)
- Relevant Obsidian patterns
- The project's FORGE_SYSTEM.md architecture

Propose **exactly 3 hypotheses** ranked by P(success):

```
[FORGE] Hypothesis proposals (ranked by P(success)):

1. [HIGH P] <type>: "<one falsifiable sentence>"
   Mechanism: <what specifically will change and why it improves SCORE>
   Target: <file:line-range>
   Pattern cite: <Obsidian pattern if applicable>

2. [MED P]  <type>: "<one falsifiable sentence>"
   ...

3. [LOW P / FORCED ARCH every 10th cycle] <type>: "<one falsifiable sentence>"
   ...
```

**Wait for human to select a hypothesis and implement it.**

## Step 4 — Evaluate after implementation

When human signals implementation is done, run evaluation:

```bash
bash ./forge-cycle.sh --skip-baseline <BASELINE_SCORE>
```

Replace `<BASELINE_SCORE>` with the score from Step 1.

## Step 5 — Report decision

The script outputs the decision (COMMIT/REVERT/HOLD/ANOMALY).

Format the final status line:
```
[FORGE] Cycle N | Type: <type> | Hypothesis: "<sentence>" | Score: X.X → Y.Y | Δ: ±Z.Z | Decision: <DECISION>
```

For ANOMALY: output `[FORGE] ANOMALY DETECTED` and guide the user through reverting.

## Rules

- Never modify `EVAL.sh` or `EVAL_SPEC.md` during a cycle (maintainer-only)
- Never propose more or fewer than 3 hypotheses
- Forced Architecture hypothesis every 10th cycle (check PROJECT_LOG.md cycle count)
- Do not commit/revert on a single EVAL run — the script handles 3-run median

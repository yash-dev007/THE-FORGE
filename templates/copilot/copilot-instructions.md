# THE FORGE — GitHub Copilot workspace instructions (adopted project)
> **Version:** 4.0 | **Last Updated:** 2026-04-16
> Place at `.github/copilot-instructions.md` in your adopted repository.

This repository uses THE FORGE research loop methodology. When working here, follow these rules:

---

## Session startup

At the start of each session, read these files in order:
1. `FORGE_IDENTITY.md` — if missing, output `[FORGE] BLOCKED — FORGE_IDENTITY.md missing` and stop.
2. `RESEARCH.md` — validate all 8 sections are filled. If any is blank or placeholder → `[FORGE] BLOCKED`.
3. `EVAL_SPEC.md` — understand the scoring weights.
4. `PROJECT_LOG.md` — context on past cycles.
5. `FORGE_SYSTEM.md` — architecture context.
6. `CLAUDE.md` — full operating rules.

---

## Running the loop

Run the Forge cycle driver from the terminal:
```bash
# Baseline only (before proposing hypotheses)
bash ./forge-cycle.sh --baseline-only

# Full interactive cycle
bash ./forge-cycle.sh

# Evaluate after implementing (skip re-running baseline)
bash ./forge-cycle.sh --skip-baseline <SCORE>
```

On Windows (PowerShell):
```powershell
.\forge-cycle.ps1 -BaselineOnly
.\forge-cycle.ps1
.\forge-cycle.ps1 -SkipBaseline 6.50
```

---

## During cycles

- **Never edit** `EVAL.sh` or `EVAL_SPEC.md` during a hypothesis cycle.
- Keep all edits within the `Target File` and `Target Scope` from `RESEARCH.md`, unless the hypothesis type is **Architecture**.
- Start every response with the status line:
  ```
  [FORGE] Cycle N | Type: <type> | Hypothesis: "..." | Score: X.X → Y.Y | Δ: ±Z.Z | Decision: ...
  ```
- Propose exactly 3 hypotheses ranked by P(success). Wait for human selection.
- On ANOMALY: output `[FORGE] ANOMALY DETECTED` — guide the user to revert and investigate.

---

## Obsidian pattern access

Read pattern files from:
- `<ObsidianVaultRoot>/Forge/Patterns/` (global)
- `<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/` (this project)

`ObsidianVaultRoot` and `ForgeProjectSlug` are in `FORGE_IDENTITY.md`.

# THE FORGE — Methodology Spec v4
> **Version:** 4.0 | **Author:** Yash | **Last Updated:** 2026-04-16
> **Philosophy:** Recursive Engineering. The loop runs itself — one command, all platforms.

This is the canonical methodology specification. The living template that gets
copied into adopted repos is `templates/universal/FORGE.md`.

See `docs/spec/CLAUDE_v3.md` for the archived v3 spec.

---

## Core principle

A Forge session is a **measurement-driven R&D loop**, not a code-editing session.
Every change is preceded by a falsifiable hypothesis and followed by a 3-run median
evaluation. Unmeasured changes are not permitted.

**The loop runs itself.** In v4, `forge-cycle.sh` handles all mechanical steps:
baseline measurement, variance detection, decision logic, PROJECT_LOG.md writes,
and Obsidian sync. The AI handles hypothesis generation and code implementation.
Humans handle selection and review.

---

## Identity & Operating Mode

You are a **Research Engineer** inside The Forge — a recursive, self-correcting
R&D pipeline.

Your operating mode: **Diagnose → Hypothesize → Execute → Verify → Synthesize.**

Scientists:
- Form falsifiable hypotheses before touching code
- Treat every failed experiment as data, not failure
- Never repeat an experiment without a changed variable
- Document causality, not just correlation

---

## Startup gate (8 steps — run once per session)

**Step 0 — Identity check**
Read `FORGE_IDENTITY.md` at the repository root.
- If missing → output `[FORGE] BLOCKED — Reason: FORGE_IDENTITY.md missing` and stop.
- Extract `ForgeProjectSlug` and `ObsidianVaultRoot`.

**Steps 1–5 — Quintet**
Read in order:
1. `RESEARCH.md` — validate all 8 required fields (see schema below). If blank/placeholder → `[FORGE] BLOCKED`.
2. `EVAL_SPEC.md` — internalize weights (PERF, QUAL, TEST, DEBT, composite formula).
3. `PROJECT_LOG.md` — last 5 cycle entries and velocity.
4. `FORGE_SYSTEM.md` — architecture context (all 6 sections).
5. `CLAUDE.md` — platform operating rules.

**Step 6 — Baseline**
Run the loop driver in baseline mode:
```bash
bash ./forge-cycle.sh --baseline-only
```
This runs EVAL.sh × 3, computes median, and prints the Forge Status Report.
Record the median COMPOSITE as `BASELINE_SCORE`.

**Step 7 — Obsidian patterns**
Read all Markdown files under:
- `<ObsidianVaultRoot>/Forge/Patterns/` — global cross-project patterns
- `<ObsidianVaultRoot>/Forge/Projects/<ForgeProjectSlug>/` — this project's history

**Step 8 — Status + hypotheses**
Output the Forge Status Report (see format below), then propose exactly 3
hypotheses ranked by P(success). Wait for human selection.

---

## RESEARCH.md — Strict Schema

All 8 fields required. `forge-cycle.sh` validates on every run.

| Field | Rule |
|-------|------|
| `Hypothesis` | One falsifiable sentence predicting a measurable improvement |
| `Hypothesis Type` | Exactly one of: **Performance** · **Correctness** · **Debt** · **Architecture** |
| `Confidence` | P(success) as a percentage: e.g. `70%` |
| `Target File` | One file path (Architecture type may list up to 3) |
| `Target Scope` | The specific function, class, or section to change |
| `Baseline Score` | The median COMPOSITE from the last 3 EVAL.sh runs, with date |
| `Goal Score` | Must be greater than Baseline Score |
| `Exploration Budget` | Max cycles before pivoting hypothesis (integer, e.g. `3`) |

Blocked approaches (optional, but populate after failures):
`Blocked Approaches` — list failed approaches to prevent cycling.

---

## The EVAL harness

`EVAL.sh` produces exactly 5 output lines:

```
SCORE: 7.23
PERF_SCORE: 6.80
QUAL_SCORE: 7.50
TEST_SCORE: 8.00
DEBT_SCORE: 6.60
```

**Dimensions:**

| Dim | Measures | Stack tools |
|-----|----------|-------------|
| PERF | Runtime performance | pytest-benchmark · vitest bench · go test -bench · cargo bench · hyperfine |
| QUAL | Code style + linting | ruff · eslint · golangci-lint · clippy |
| TEST | Test coverage + pass rate | pytest · npm test / vitest · go test · cargo test |
| DEBT | Cyclomatic complexity | radon · eslint complexity · gocyclo · cargo-geiger |

**COMPOSITE formula:**
```
SCORE = (PERF × w_p + QUAL × w_q + TEST × w_t + DEBT × w_d) / (w_p + w_q + w_t + w_d)
```
Weights defined in `EVAL_SPEC.md`.

**EVAL.sh rules (anti-gaming):**
- Never edit `EVAL.sh` during a hypothesis cycle. It is locked — edits void the cycle.
- Never edit `EVAL_SPEC.md` during a cycle.
- Run × 3 before any cycle; take the **median**. Ignore min/max.
- If max−min spread > 0.3, the harness is flaky. Stop. Fix before cycling.

---

## The loop driver (`forge-cycle.sh`)

`forge-cycle.sh` is the mechanical backbone. It replaces all manual measurement steps.

```
bash ./forge-cycle.sh                    # Full interactive cycle
bash ./forge-cycle.sh --baseline-only    # Steps 1–4 only (for AI platform integration)
bash ./forge-cycle.sh --skip-baseline N  # Steps 6–11 only, using N as baseline
```

Steps executed by the driver:
1. Validate FORGE_IDENTITY.md + RESEARCH.md (all 8 fields)
2. Run EVAL.sh × 3 → compute median BASELINE_SCORE
3. Print Forge Status Report
4. [PAUSE] Wait for human implementation (full mode) OR exit (baseline-only mode)
5. Run EVAL.sh × 3 → compute median NEW_SCORE
6. Anti-gaming check (sub-score anomaly detection)
7. Decision: COMMIT / REVERT / HOLD / ANOMALY
8. Append cycle entry to PROJECT_LOG.md
9. Call forge-obsidian-sync.sh (if ObsidianVaultRoot is set)
10. Print next action

See [LOOP_DRIVER.md](../LOOP_DRIVER.md) for full documentation.

---

## Anti-gaming rules

The harness enforces five anti-gaming rules:

1. **One variable:** Only one mechanism changes per cycle. If multiple changes were
   made, the cycle is void — revert and re-run with a single change.

2. **Sub-score anomaly:** If any sub-score (PERF, QUAL, TEST, DEBT) moves by more
   than ±3.0 in a single cycle, the driver outputs `[FORGE] ANOMALY DETECTED` and
   recommends reverting. Investigate before continuing.

3. **EVAL.sh is locked:** You may not edit `EVAL.sh` or `EVAL_SPEC.md` during a
   hypothesis cycle. These files define the rules of the experiment.

4. **Median, not best:** Always use the median of 3 runs. Cherry-picking the best
   run is forbidden.

5. **Prediction required:** Each hypothesis must include a specific predicted Δ
   (e.g. "SCORE +0.5"). Vague claims ("should be faster") are not hypotheses.

---

## Status line format

Every AI response during a Forge session must begin with:
```
[FORGE] Cycle N | Type: <type> | Hypothesis: "<one sentence>" | Score: X.X → Y.Y | Δ: ±Z.Z | Decision: COMMIT/REVERT/HOLD/BLOCKED/ANOMALY
```

---

## Obsidian integration

After each cycle, `forge-obsidian-sync.sh` (called by `forge-cycle.sh`):
- Appends a row to `Forge/Projects/<slug>/01-Score-History.md`
- Updates `Forge/Projects/<slug>/00-Project-Index.md` (win rate, last score)
- Detects pattern candidates: same mechanism COMMIT-ed ≥ 2 times → print promotion prompt

Patterns require ≥ 2 distinct projects before promotion to `Forge/Patterns/`.
Never auto-write to `Forge/Patterns/` — always human-gated.

---

## Platform compatibility

v4 supports five platforms with identical loop semantics:

| Platform | Bridge file | Invokes forge-cycle.sh via |
|----------|-------------|---------------------------|
| Claude Code | `.claude/CLAUDE.md` | Bash tool |
| Gemini CLI | `GEMINI.md` | run_shell_command |
| Cursor | `.cursor/rules/forge.mdc` | Terminal panel |
| Codex | `program.md` | Shell tool |
| GitHub Copilot | `.github/copilot-instructions.md` | Terminal (manual) |

See [PLATFORMS.md](../PLATFORMS.md) for per-platform setup and usage.

---

## Velocity and Auditor protocol

**Velocity Report** — every 5 cycles:
```
Win Rate: X / 5 cycles  (committed / total)
Avg Δ:    ±Z.Z per cycle
Trend:    IMPROVING / STAGNATING / DECLINING
```

**Auditor Review** — every 5 commits OR when win rate ≤ 40% for 3 consecutive
velocity blocks:

The Auditor asks 7 questions:
1. Is RESEARCH.md complete with no placeholders?
2. Was the one-variable rule followed in every cycle?
3. Do the PROJECT_LOG.md deltas match the EVAL.sh outputs?
4. Are any sub-scores anomalous?
5. Is FORGE_SYSTEM.md still accurate for the current architecture?
6. Are Blocked Approaches populated with real learnings?
7. Is the pattern library growing? (≥ 1 promotion per 10 cycles is healthy)

**Stagnation:** 3 consecutive velocity blocks with ≤ 40% win rate in this repo's
log triggers a mandatory Auditor + hypothesis pivot review.

---

## Changes from v3

| v3 | v4 |
|----|-----|
| Manual EVAL.sh × 3 each cycle | `forge-cycle.sh` automates all measurement steps |
| Manual PROJECT_LOG.md writes | forge-cycle.sh appends cycle entries automatically |
| No Obsidian automation | forge-obsidian-sync.sh updates Score History automatically |
| 4 platforms | 5 platforms (added Codex, Copilot) |
| 4 stacks | 5 stacks (added Rust / Criterion) |
| Static PERF_SCORE (placeholder) | Real benchmarks: pytest-benchmark, vitest bench, go test -bench, cargo bench |
| 20-minute manual setup | `--interactive` mode: zero-to-first-EVAL in < 5 minutes |
| Empty pattern library | 16 pre-seeded patterns (Python · Node · Go · Universal) |
| forge-adopt copies 4 platforms | forge-adopt --platforms flag (select which platforms to copy) |

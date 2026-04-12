# EVAL_SPEC — minimal / noop harness

Use this stack when you only need **parseable score lines** and a stable harness while wiring real metrics later.

## Weights (composite `SCORE`)

| Dimension | Weight |
|-----------|--------|
| PERF_SCORE | 0.25 |
| QUAL_SCORE | 0.25 |
| TEST_SCORE | 0.25 |
| DEBT_SCORE | 0.25 |

`SCORE = sum(weight_i * dimension_i)`.

## Exit codes (`EVAL.sh`)

| Code | Meaning |
|------|---------|
| 0 | Harness completed successfully |
| 1 | Product / tests failed (not used in minimal noop) |
| 2 | Harness misconfiguration (missing deps, internal error) |

## Anti-gaming

See `CLAUDE.md` in the adopted repository. Replace this noop with real signals before trusting commit/revert decisions.

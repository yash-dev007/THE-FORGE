# EVAL_SPEC — Python starter

Tune commands and weights after adoption. Agents must not edit this file during hypothesis cycles.

## Weights

| Dimension | Weight | Source in `EVAL.sh` |
|-----------|--------|---------------------|
| PERF_SCORE | 0.20 | Placeholder constant (add benchmark script) |
| QUAL_SCORE | 0.25 | `ruff check .` if available, else neutral |
| TEST_SCORE | 0.35 | `pytest` when present and discoverable |
| DEBT_SCORE | 0.20 | `radon cc -a` average if available, else neutral |

Composite: `SCORE = 0.20*PERF + 0.25*QUAL + 0.35*TEST + 0.20*DEBT` (rounded to 2 decimals in script).

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Harness finished; inspect scores |
| 1 | Tests failed (`pytest` non-zero) |
| 2 | Environment error (e.g. `python` missing) |

## Optional tools

- `pytest`, `ruff`, `radon` — install in your project dev dependencies for meaningful sub-scores.

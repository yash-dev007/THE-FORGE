# EVAL_SPEC — Node.js starter

Tune commands and weights after adoption. Agents must not edit this file during
hypothesis cycles (write-protected by `CLAUDE.md` Rule 1). Human maintainers may
edit for adoption, stack upgrades, or scorecard redesign only.

## Weights

| Dimension | Weight | Source in `EVAL.sh` |
|-----------|--------|---------------------|
| PERF_SCORE | 0.20 | Placeholder constant — see `docs/CUSTOMIZING_EVAL.md` to wire benchmarks |
| QUAL_SCORE | 0.25 | `eslint . --max-warnings=0` if eslint + config present; else neutral |
| TEST_SCORE | 0.35 | `npm test` when `package.json` defines a `test` script (`CI=true`) |
| DEBT_SCORE | 0.20 | `eslint . --rule 'complexity: ["warn", 10]' --format compact` — CC > 10 violations reduce from 9.0 toward 3.0 |

Composite: `SCORE = 0.20*PERF + 0.25*QUAL + 0.35*TEST + 0.20*DEBT` (rounded to 2 decimals).

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Harness finished; inspect score lines |
| 1 | Tests failed (`npm test` non-zero) |
| 2 | Environment error (`node` not on PATH) |

## Optional tools

| Tool | Dimension | Install |
|------|-----------|---------|
| `eslint` | QUAL + DEBT | `npm install --save-dev eslint` |
| eslint config | QUAL + DEBT | Required — one of `eslint.config.{js,mjs,cjs}` or `.eslintrc.*` |
| `autocannon` | PERF | `npm install --save-dev autocannon` (see `docs/CUSTOMIZING_EVAL.md`) |
| `hyperfine` | PERF | System package or `pip install hyperfine` (alternative) |

## DEBT_SCORE interpretation

The eslint `complexity` rule counts functions where cyclomatic complexity exceeds 10.
Each violation reduces the score by 0.35 (minimum 3.0):

| Violations | DEBT_SCORE |
|-----------|------------|
| 0 | 9.0 |
| 5 | ~7.3 |
| 10 | ~6.5 |
| 20 | ~3.0 (floor) |

Adjust the threshold (default 10) in `EVAL.sh` if your codebase has a higher baseline.
After changing the threshold, re-run × 3 and record the new baseline in `RESEARCH.md`.

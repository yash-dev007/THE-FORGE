# EVAL_SPEC — Go starter

Tune commands and weights after adoption. Agents must not edit this file during
hypothesis cycles (write-protected by `CLAUDE.md` Rule 1). Human maintainers may
edit for adoption, stack upgrades, or scorecard redesign only.

## Weights

| Dimension | Weight | Source in `EVAL.sh` |
|-----------|--------|---------------------|
| PERF_SCORE | 0.20 | Placeholder constant — see `docs/EVAL_BENCHMARKS.md` to wire `go test -bench` |
| QUAL_SCORE | 0.25 | `golangci-lint run` if on PATH; else neutral |
| TEST_SCORE | 0.35 | `go test ./... -count=1 -short` |
| DEBT_SCORE | 0.20 | `gocyclo -over 10 .` — functions with CC > 10 reduce from 9.0 toward 3.0 |

Composite: `SCORE = 0.20*PERF + 0.25*QUAL + 0.35*TEST + 0.20*DEBT` (rounded to 2 decimals).

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Harness finished; inspect score lines |
| 1 | `go test` failed |
| 2 | Environment error (`go` not on PATH) |

## Optional tools

| Tool | Dimension | Install |
|------|-----------|---------|
| `golangci-lint` | QUAL | `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` |
| `gocyclo` | DEBT | `go install github.com/fzipp/gocyclo/cmd/gocyclo@latest` |
| `go test -bench` | PERF | Built-in — add `Benchmark*` funcs; see `docs/EVAL_BENCHMARKS.md` |
| `hyperfine` | PERF | System package (alternative to go bench) |

## DEBT_SCORE interpretation

`gocyclo -over 10 .` lists functions exceeding cyclomatic complexity 10.
Each such function reduces the score by 0.5 (minimum 3.0):

| Over-limit functions | DEBT_SCORE |
|----------------------|------------|
| 0 | 9.0 |
| 5 | 6.5 |
| 10 | 4.0 |
| 14+ | 3.0 (floor) |

To raise the threshold (e.g. legacy code with many complex functions), change
`-over 10` in `EVAL.sh` to `-over 15` or similar. Document the change in
`FORGE_SYSTEM.md` under **Scorecard rationale** so the Auditor can evaluate it.

## PERF_SCORE — go test -bench wiring

Add a `BenchmarkHotPath` function (or rename via `FORGE_BENCH_FUNC` env var) in
your test files and follow the snippet in `docs/EVAL_BENCHMARKS.md`. The Go stack
template parses `ns/op` from bench output and maps it to a 2.0–10.0 range using
calibrated thresholds you define per project.

#!/usr/bin/env bash
# Go-oriented Forge evaluator — starter template.
#
# PERF_SCORE: static placeholder (6.0) — wire a real benchmark per your project.
#             See docs/CUSTOMIZING_EVAL.md for go test -bench and hyperfine options.
# QUAL_SCORE: golangci-lint (pass → 9.0; any issues → 3.0).
# TEST_SCORE: go test ./... short mode (pass → 10.0; fail → 0.0).
# DEBT_SCORE: gocyclo — counts functions with cyclomatic complexity > 10.
#             Score 9.0 at 0 violations, decreasing by 0.5 per over-limit function (floor 3.0).
#             Install: go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
#
# Agents must NOT edit this file during hypothesis cycles (write-protected by CLAUDE.md Rule 1).
# Human maintainers may edit for adoption, stack upgrades, or harness repair only.
set -euo pipefail

EXIT=0

# PERF_SCORE: replace this line with a benchmark integration (see docs/CUSTOMIZING_EVAL.md).
PERF_SCORE=6.0
QUAL_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once golangci-lint runs
TEST_SCORE=5.0   # 5.0 = not yet measured; rises to 0.0 or 10.0 once go test runs
DEBT_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once gocyclo runs

# ── Runtime check ──────────────────────────────────────────────────────────────
if ! command -v go >/dev/null 2>&1; then
  echo "FORGE_EVAL_ERR: go not found" >&2
  printf "PERF_SCORE: 0.0\nQUAL_SCORE: 0.0\nTEST_SCORE: 0.0\nDEBT_SCORE: 0.0\nSCORE: 0.0\n"
  exit 2
fi

# ── TEST_SCORE ─────────────────────────────────────────────────────────────────
if go test ./... -count=1 -short 2>/dev/null; then
  TEST_SCORE=10.0
else
  TEST_SCORE=0.0
  EXIT=1
fi

# ── QUAL_SCORE — golangci-lint ─────────────────────────────────────────────────
if command -v golangci-lint >/dev/null 2>&1; then
  if golangci-lint run --timeout=5m >/dev/null 2>&1; then
    QUAL_SCORE=9.0
  else
    QUAL_SCORE=3.0
  fi
else
  echo "FORGE_EVAL_WARN: golangci-lint not found; QUAL_SCORE left at default" >&2
fi

# ── DEBT_SCORE — cyclomatic complexity via gocyclo ─────────────────────────────
# Install: go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
if command -v gocyclo >/dev/null 2>&1; then
  COMPLEX_COUNT=$(gocyclo -over 10 . 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)
  if [[ "$COMPLEX_COUNT" -eq 0 ]]; then
    DEBT_SCORE=9.0
  else
    DEBT_SCORE=$(awk -v c="$COMPLEX_COUNT" 'BEGIN{v=10.0-c*0.5; if(v<3.0)v=3.0; printf "%.2f",v}')
  fi
else
  echo "FORGE_EVAL_WARN: gocyclo not found (go install github.com/fzipp/gocyclo/cmd/gocyclo@latest); DEBT_SCORE left at default" >&2
fi

# ── SCORE composite ────────────────────────────────────────────────────────────
SCORE=$(awk -v p="$PERF_SCORE" -v q="$QUAL_SCORE" -v t="$TEST_SCORE" -v d="$DEBT_SCORE" \
  'BEGIN{printf "%.2f", 0.20*p+0.25*q+0.35*t+0.20*d}')

echo "PERF_SCORE: ${PERF_SCORE}"
echo "QUAL_SCORE: ${QUAL_SCORE}"
echo "TEST_SCORE: ${TEST_SCORE}"
echo "DEBT_SCORE: ${DEBT_SCORE}"
echo "SCORE: ${SCORE}"
exit "$EXIT"

#!/usr/bin/env bash
# Python-oriented Forge evaluator — starter template.
#
# PERF_SCORE: static placeholder (6.0) — wire a real benchmark per your project.
#             See docs/CUSTOMIZING_EVAL.md for pytest-benchmark and hyperfine options.
# QUAL_SCORE: ruff check (clean → 9.0; any issues → 3.0).
# TEST_SCORE: pytest (all pass → 10.0; any fail → 0.0).
# DEBT_SCORE: radon cyclomatic complexity average (CC ≤ 5 → ~9.0, higher CC → lower score).
#
# Agents must NOT edit this file during hypothesis cycles (write-protected by CLAUDE.md Rule 1).
# Human maintainers may edit for adoption, stack upgrades, or harness repair only.
set -euo pipefail

EXIT=0
# PERF_SCORE: replace this line with a benchmark integration (see docs/CUSTOMIZING_EVAL.md).
PERF_SCORE=6.0
QUAL_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once ruff runs
TEST_SCORE=5.0   # 5.0 = not yet measured; rises to 0.0 or 10.0 once pytest runs
DEBT_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once radon runs

if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
  echo "FORGE_EVAL_ERR: python not found" >&2
  echo "PERF_SCORE: 0.0"
  echo "QUAL_SCORE: 0.0"
  echo "TEST_SCORE: 0.0"
  echo "DEBT_SCORE: 0.0"
  echo "SCORE: 0.0"
  exit 2
fi

PY=python3
command -v python3 >/dev/null 2>&1 || PY=python

if command -v pytest >/dev/null 2>&1; then
  if "$PY" -m pytest -q --tb=no 2>/dev/null; then
    TEST_SCORE=10.0
  else
    TEST_SCORE=0.0
    EXIT=1
  fi
else
  echo "FORGE_EVAL_WARN: pytest not found; TEST_SCORE left at default" >&2
fi

if command -v ruff >/dev/null 2>&1; then
  if ruff check . >/dev/null 2>&1; then
    QUAL_SCORE=9.0
  else
    QUAL_SCORE=3.0
  fi
fi

if command -v radon >/dev/null 2>&1; then
  DEBT_SCORE=$($PY <<'PY'
import subprocess, re
try:
    out = subprocess.run(["radon", "cc", "-a", "."], capture_output=True, text=True, timeout=120).stdout
    m = re.search(r"Average complexity:\s*\S+\s*\(([\d.]+)\)", out)
    if not m:
        print("6.0")
    else:
        avg = float(m.group(1))
        print(f"{max(0.0, min(10.0, 10.0 - max(0.0, avg - 5.0) * 1.2)):.2f}")
except Exception:
    print("6.0")
PY
) || DEBT_SCORE=6.0
fi

SCORE=$($PY - <<PY
p, q, t, d = $PERF_SCORE, $QUAL_SCORE, $TEST_SCORE, $DEBT_SCORE
print(round(0.20 * p + 0.25 * q + 0.35 * t + 0.20 * d, 2))
PY
)

echo "PERF_SCORE: ${PERF_SCORE}"
echo "QUAL_SCORE: ${QUAL_SCORE}"
echo "TEST_SCORE: ${TEST_SCORE}"
echo "DEBT_SCORE: ${DEBT_SCORE}"
echo "SCORE: ${SCORE}"
exit "$EXIT"

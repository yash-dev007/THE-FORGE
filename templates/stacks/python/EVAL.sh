#!/usr/bin/env bash
# Python-oriented Forge evaluator — starter template.
#
# PERF_SCORE: pytest-benchmark (benchmark.py) → median ops/sec mapped to 0–10.
#             Falls back to hyperfine if FORGE_BENCH_CMD is set in FORGE_IDENTITY.md.
#             Falls back to 6.0 placeholder if neither is configured.
#             See docs/EVAL_BENCHMARKS.md for details.
# QUAL_SCORE: ruff check (clean → 9.0; any issues → 3.0).
# TEST_SCORE: pytest (all pass → 10.0; none collected → 5.0 default; any fail → 0.0).
# DEBT_SCORE: radon cyclomatic complexity average (CC ≤ 5 → ~9.0, higher CC → lower score).
#
# Agents must NOT edit this file during hypothesis cycles (write-protected by CLAUDE.md Rule 1).
# Human maintainers may edit for adoption, stack upgrades, or harness repair only.
set -euo pipefail

EXIT=0
PERF_SCORE=6.0   # default placeholder; overridden below if benchmark tools are present
QUAL_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once ruff runs
TEST_SCORE=5.0   # 5.0 = not yet measured; rises to 0.0 or 10.0 once pytest runs
DEBT_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once radon runs

# Read optional FORGE_BENCH_CMD from FORGE_IDENTITY.md (hyperfine fallback)
FORGE_BENCH_CMD=""
if [[ -f FORGE_IDENTITY.md ]]; then
  FORGE_BENCH_CMD=$(grep -i 'FORGE_BENCH_CMD' FORGE_IDENTITY.md | head -1 | sed 's/.*: *//' | tr -d '"' || true)
fi

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

# ── PERF_SCORE ─────────────────────────────────────────────────────────────────
BENCH_JSON_FILE="/tmp/forge_bench_$$.json"
HF_JSON_FILE="/tmp/forge_hf_$$.json"

# Strategy 1: pytest-benchmark (benchmark.py in repo root)
if command -v pytest >/dev/null 2>&1 && [[ -f benchmark.py ]]; then
  set +e
  "$PY" -m pytest benchmark.py --benchmark-only \
    --benchmark-json="$BENCH_JSON_FILE" -q >/dev/null 2>&1
  BENCH_EXIT=$?
  set -e
  if [[ $BENCH_EXIT -eq 0 && -f "$BENCH_JSON_FILE" ]]; then
    PERF_SCORE=$(FORGE_BENCH_JSON="$BENCH_JSON_FILE" "$PY" - <<'PY'
import json, sys, math, os
try:
    with open(os.environ["FORGE_BENCH_JSON"]) as f:
        data = json.load(f)
    benchmarks = data.get("benchmarks", [])
    ops_list = [b["stats"]["ops"] for b in benchmarks if "ops" in b.get("stats", {})]
    if not ops_list:
        print("6.0"); sys.exit()
    median_ops = sorted(ops_list)[len(ops_list) // 2]
    # log10 scale: 100 ops/s→2.0, 10k→4.0, 1M→8.0, capped at 10.0
    score = min(10.0, max(0.0, (math.log10(max(1, median_ops)) - 2) * 2.0))
    print(f"{score:.2f}")
except Exception:
    print("6.0")
PY
) || PERF_SCORE=6.0
    rm -f "$BENCH_JSON_FILE"
  else
    echo "FORGE_EVAL_WARN: pytest-benchmark failed; trying hyperfine" >&2
  fi
fi

# Strategy 2: hyperfine (FORGE_BENCH_CMD set in FORGE_IDENTITY.md)
if [[ "$PERF_SCORE" == "6.0" && -n "$FORGE_BENCH_CMD" ]] && command -v hyperfine >/dev/null 2>&1; then
  set +e
  hyperfine --runs 5 --export-json "$HF_JSON_FILE" "$FORGE_BENCH_CMD" >/dev/null 2>&1
  HF_EXIT=$?
  set -e
  if [[ $HF_EXIT -eq 0 && -f "$HF_JSON_FILE" ]]; then
    PERF_SCORE=$(FORGE_HF_JSON="$HF_JSON_FILE" "$PY" - <<'PY'
import json, sys, math, os
try:
    with open(os.environ["FORGE_HF_JSON"]) as f:
        data = json.load(f)
    median_s = data["results"][0]["median"]
    # Map seconds → score: 0.001s→10, 0.1s→7.5, 1s→5, 10s→2.5
    score = max(0.0, min(10.0, 10.0 - math.log10(max(0.001, median_s)) * 2.5))
    print(f"{score:.2f}")
except Exception:
    print("6.0")
PY
) || PERF_SCORE=6.0
    rm -f "$HF_JSON_FILE"
  else
    echo "FORGE_EVAL_WARN: hyperfine failed; PERF_SCORE left at placeholder" >&2
  fi
elif [[ "$PERF_SCORE" == "6.0" ]]; then
  echo "FORGE_EVAL_WARN: no benchmark configured (no benchmark.py, no FORGE_BENCH_CMD); PERF_SCORE=6.0 placeholder — see docs/EVAL_BENCHMARKS.md" >&2
fi

# ── TEST_SCORE ─────────────────────────────────────────────────────────────────
if command -v pytest >/dev/null 2>&1; then
  set +e
  "$PY" -m pytest -q --tb=no --ignore=benchmark.py 2>/dev/null
  PYTEST_EXIT=$?
  set -e
  if [[ $PYTEST_EXIT -eq 0 ]]; then
    TEST_SCORE=10.0
  elif [[ $PYTEST_EXIT -eq 5 ]]; then
    echo "FORGE_EVAL_WARN: no tests found; TEST_SCORE left at default" >&2
  else
    TEST_SCORE=0.0
    EXIT=1
  fi
else
  echo "FORGE_EVAL_WARN: pytest not found; TEST_SCORE left at default" >&2
fi

# ── QUAL_SCORE ─────────────────────────────────────────────────────────────────
if command -v ruff >/dev/null 2>&1; then
  if ruff check . >/dev/null 2>&1; then
    QUAL_SCORE=9.0
  else
    QUAL_SCORE=3.0
  fi
fi

# ── DEBT_SCORE ─────────────────────────────────────────────────────────────────
if command -v radon >/dev/null 2>&1; then
  DEBT_SCORE=$("$PY" - <<'PY'
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

# ── Composite SCORE ────────────────────────────────────────────────────────────
SCORE=$("$PY" - <<PY
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

#!/usr/bin/env bash
# Rust-oriented Forge evaluator — starter template.
#
# PERF_SCORE: cargo bench (Criterion) → ns/iter mapped to 0–10.
#             Falls back to hyperfine if FORGE_BENCH_CMD is set in FORGE_IDENTITY.md.
#             Falls back to 6.0 placeholder if neither is configured.
#             See docs/EVAL_BENCHMARKS.md for Criterion and hyperfine options.
# QUAL_SCORE: cargo clippy — warnings-as-errors (0 warnings → 9.0; any → 3.0).
# TEST_SCORE: cargo test (pass → 10.0; fail → 0.0).
# DEBT_SCORE: cargo clippy complexity lints — counts complexity warnings.
#
# Agents must NOT edit this file during hypothesis cycles (write-protected by CLAUDE.md Rule 1).
# Human maintainers may edit for adoption, stack upgrades, or harness repair only.
set -euo pipefail

EXIT=0

PERF_SCORE=6.0   # default placeholder; overridden below if benchmarks exist
QUAL_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once clippy runs
TEST_SCORE=5.0   # 5.0 = not yet measured; rises to 0.0 or 10.0 once cargo test runs
DEBT_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once complexity lints run

# Read optional FORGE_BENCH_CMD from FORGE_IDENTITY.md (hyperfine fallback)
FORGE_BENCH_CMD=""
if [[ -f FORGE_IDENTITY.md ]]; then
  FORGE_BENCH_CMD=$(grep -i 'FORGE_BENCH_CMD' FORGE_IDENTITY.md | head -1 | sed 's/.*: *//' | tr -d '"' || true)
fi

# ── Runtime check ──────────────────────────────────────────────────────────────
if ! command -v cargo >/dev/null 2>&1; then
  echo "FORGE_EVAL_ERR: cargo not found (install Rust via https://rustup.rs)" >&2
  printf "PERF_SCORE: 0.0\nQUAL_SCORE: 0.0\nTEST_SCORE: 0.0\nDEBT_SCORE: 0.0\nSCORE: 0.0\n"
  exit 2
fi

# Helper: parse hyperfine JSON median → score
_parse_hf_json() {
  local file="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PY
import json, math
try:
    with open("${file}") as f:
        data = json.load(f)
    med = data["results"][0]["median"]
    score = max(0.0, min(10.0, 10.0 - math.log10(max(0.001, med)) * 2.5))
    print(f"{score:.2f}")
except Exception:
    print("6.0")
PY
  else
    local med
    med=$(grep -oE '"median":[[:space:]]*[0-9.]+' "$file" | head -1 | grep -oE '[0-9.]+$' || echo "1")
    awk -v med="$med" 'BEGIN{
      score = 10.0 - log(med < 0.001 ? 0.001 : med+0) / log(10) * 2.5
      if (score > 10) score = 10; if (score < 0) score = 0
      printf "%.2f\n", score
    }'
  fi
}

# ── PERF_SCORE ─────────────────────────────────────────────────────────────────
# Strategy 1: cargo bench (Criterion in benches/)
BENCH_EXISTS=false
[[ -d benches ]] && ls benches/*.rs >/dev/null 2>&1 && BENCH_EXISTS=true

if [[ "$BENCH_EXISTS" == "true" ]]; then
  BENCH_OUT_FILE="/tmp/forge_rustbench_$$.txt"
  set +e
  cargo bench 2>/dev/null | tee "$BENCH_OUT_FILE" >/dev/null
  CARGO_BENCH_EXIT=$?
  set -e
  if [[ $CARGO_BENCH_EXIT -eq 0 && -s "$BENCH_OUT_FILE" ]]; then
    # Criterion output: "forge_bench    time:   [X.XX µs X.XX µs X.XX µs]"
    # Extract median (middle value), convert to ns, map to score
    PERF_SCORE=$(awk '
      /time:/ {
        # Find three timing values in brackets
        if (match($0, /\[([0-9.]+) ([a-zµ]+)/, arr)) {
          # Use first value as representative (lower bound)
          val = arr[1] + 0
          unit = arr[2]
          # Normalize to nanoseconds
          if (unit == "ns") ns = val
          else if (unit == "µs" || unit == "us") ns = val * 1000
          else if (unit == "ms") ns = val * 1000000
          else if (unit == "s")  ns = val * 1000000000
          else ns = val
          vals[n++] = ns
        }
      }
      END {
        if (n == 0) { print "6.0"; exit }
        for(i=0;i<n-1;i++) for(j=i+1;j<n;j++) if(vals[i]>vals[j]){t=vals[i];vals[i]=vals[j];vals[j]=t}
        med = vals[int(n/2)]
        if (med <= 0) { print "6.0"; exit }
        log10_med = log(med) / log(10)
        score = 10.0 - log10_med * 0.83
        if (score > 10) score = 10; if (score < 0) score = 0
        printf "%.2f\n", score
      }
    ' "$BENCH_OUT_FILE") || PERF_SCORE=6.0
    rm -f "$BENCH_OUT_FILE"
  else
    echo "FORGE_EVAL_WARN: cargo bench failed; trying hyperfine" >&2
    rm -f "$BENCH_OUT_FILE" 2>/dev/null || true
  fi
fi

# Strategy 2: hyperfine (FORGE_BENCH_CMD set in FORGE_IDENTITY.md)
if [[ "$PERF_SCORE" == "6.0" && -n "$FORGE_BENCH_CMD" ]] && command -v hyperfine >/dev/null 2>&1; then
  HF_JSON_FILE="/tmp/forge_hf_$$.json"
  set +e
  hyperfine --runs 5 --export-json "$HF_JSON_FILE" "$FORGE_BENCH_CMD" >/dev/null 2>&1
  HF_EXIT=$?
  set -e
  if [[ $HF_EXIT -eq 0 && -f "$HF_JSON_FILE" ]]; then
    PERF_SCORE=$(_parse_hf_json "$HF_JSON_FILE") || PERF_SCORE=6.0
    rm -f "$HF_JSON_FILE"
  else
    echo "FORGE_EVAL_WARN: hyperfine failed; PERF_SCORE left at placeholder" >&2
  fi
elif [[ "$PERF_SCORE" == "6.0" && "$BENCH_EXISTS" == "false" ]]; then
  echo "FORGE_EVAL_WARN: no benches/ directory, no FORGE_BENCH_CMD; PERF_SCORE=6.0 placeholder — see docs/EVAL_BENCHMARKS.md" >&2
fi

# ── TEST_SCORE ─────────────────────────────────────────────────────────────────
set +e
cargo test --quiet 2>/dev/null
CARGO_TEST_EXIT=$?
set -e
if [[ $CARGO_TEST_EXIT -eq 0 ]]; then
  TEST_SCORE=10.0
else
  TEST_SCORE=0.0
  EXIT=1
fi

# ── QUAL_SCORE ─────────────────────────────────────────────────────────────────
set +e
CLIPPY_OUTPUT=$(cargo clippy -- -D warnings 2>&1)
CLIPPY_EXIT=$?
set -e
if [[ $CLIPPY_EXIT -eq 0 ]]; then
  QUAL_SCORE=9.0
else
  QUAL_SCORE=3.0
fi

# ── DEBT_SCORE ─────────────────────────────────────────────────────────────────
# Count clippy complexity-related warnings (cognitive_complexity, too_many_arguments, etc.)
COMPLEXITY_WARNS=$(echo "$CLIPPY_OUTPUT" | grep -cE 'cognitive_complexity|too_many_arguments|too_many_lines|cyclomatic' 2>/dev/null || echo 0)
if [[ "$COMPLEXITY_WARNS" -eq 0 ]]; then
  DEBT_SCORE=9.0
else
  DEBT_SCORE=$(awk -v c="$COMPLEXITY_WARNS" 'BEGIN{v=10.0-c*0.5; if(v<3.0)v=3.0; printf "%.2f",v}')
fi

# ── Composite SCORE ────────────────────────────────────────────────────────────
SCORE=$(awk -v p="$PERF_SCORE" -v q="$QUAL_SCORE" -v t="$TEST_SCORE" -v d="$DEBT_SCORE" \
  'BEGIN{printf "%.2f", 0.20*p+0.25*q+0.35*t+0.20*d}')

echo "PERF_SCORE: ${PERF_SCORE}"
echo "QUAL_SCORE: ${QUAL_SCORE}"
echo "TEST_SCORE: ${TEST_SCORE}"
echo "DEBT_SCORE: ${DEBT_SCORE}"
echo "SCORE: ${SCORE}"
exit "$EXIT"

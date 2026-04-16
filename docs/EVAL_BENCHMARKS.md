# Customizing EVAL.sh — wiring real metrics

Every EVAL.sh starter ships with `PERF_SCORE=6.0` as a static placeholder.
The three real stacks (python, node, go) measure TEST, QUAL, and DEBT automatically,
but **Performance** requires a project-specific benchmark — because what "performance"
means depends entirely on your application.

This guide shows how to wire PERF_SCORE for each stack.

> **Baseline rule:** Any change to EVAL.sh resets the baseline. After editing,
> re-run EVAL.sh × 3, record the new median in RESEARCH.md, and note the harness
> change in PROJECT_LOG.md before resuming hypothesis cycles. Agents must not edit
> EVAL.sh during cycles — this is a human/maintainer task.

---

## Guiding principle

PERF_SCORE must be **reproducible** and **mechanistic**:
- Same code → same score within ±0.2 on repeated runs (check flakiness before use)
- Lower runtime → higher score (not vice versa)
- Never tie PERF_SCORE to wall-clock time on a shared CI machine without warmup

---

## Python stack

### Option A — pytest-benchmark (recommended for unit-level perf)

Install: `pip install pytest-benchmark`

Add to your test suite:
```python
# tests/bench/test_hot_path.py
def test_my_function_benchmark(benchmark):
    benchmark(my_function, *args)
```

EVAL.sh snippet (replace the static PERF_SCORE line):
```bash
# PERF_SCORE via pytest-benchmark (lower mean = higher score)
if command -v pytest >/dev/null 2>&1 && "$PY" -m pytest --collect-only -q tests/bench/ >/dev/null 2>&1; then
  BENCH_JSON=$(mktemp /tmp/forge_bench_XXXXXX.json)
  "$PY" -m pytest tests/bench/ --benchmark-json="$BENCH_JSON" -q --tb=no 2>/dev/null || true
  PERF_SCORE=$("$PY" - <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1]))
    mean_ns = data['benchmarks'][0]['stats']['mean'] * 1e9
    # Score: 10.0 at ≤ 1ms, 5.0 at 100ms, 2.0 at 1s — adjust thresholds per project
    import math
    score = max(2.0, 10.0 - math.log10(max(1, mean_ns / 1e6)) * 2.0)
    print(f"{score:.2f}")
except Exception:
    print("6.0")
PY
"$BENCH_JSON") || PERF_SCORE=6.0
  rm -f "$BENCH_JSON"
else
  echo "FORGE_EVAL_WARN: pytest-benchmark not found or no bench/ tests; PERF_SCORE left at default" >&2
fi
```

### Option B — hyperfine (CLI / subprocess benchmarks)

Install: `pip install hyperfine` or use system package.

```bash
# PERF_SCORE via hyperfine (runs your CLI entrypoint)
if command -v hyperfine >/dev/null 2>&1; then
  MEAN_MS=$(hyperfine --warmup 3 --runs 10 --export-json /tmp/forge_hf.json \
    "python -m myapp --bench-mode" 2>/dev/null \
    && "$PY" -c "import json; d=json.load(open('/tmp/forge_hf.json')); print(d['results'][0]['mean']*1000)" \
    || echo "0")
  # 10.0 at < 50ms, sliding to 3.0 at > 500ms — calibrate per project
  PERF_SCORE=$("$PY" -c "ms=$MEAN_MS; print(round(max(3.0, 10.0 - max(0, ms - 50) / 50.0), 2))")
else
  echo "FORGE_EVAL_WARN: hyperfine not found; PERF_SCORE left at default" >&2
fi
```

---

## Node.js stack

### Option A — autocannon (HTTP load test)

Install: `npm install --save-dev autocannon`

```bash
# PERF_SCORE via autocannon (start server, run load test, stop server)
if command -v autocannon >/dev/null 2>&1 || npx autocannon --version >/dev/null 2>&1; then
  # Start server in background
  node server.js &
  SERVER_PID=$!
  sleep 1  # allow startup
  # Run load test — capture requests/sec
  RPS=$(npx autocannon -d 5 -c 10 --json http://localhost:3000/health 2>/dev/null \
    | node -p "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).requests.average" \
    || echo 0)
  kill "$SERVER_PID" 2>/dev/null || true
  # 10.0 at ≥ 1000 rps, 5.0 at 100 rps, 2.0 at 10 rps — calibrate per project
  PERF_SCORE=$(node -p "Math.max(2.0, Math.min(10.0, parseFloat(($RPS / 100.0).toFixed(2))))")
else
  echo "FORGE_EVAL_WARN: autocannon not found; PERF_SCORE left at default" >&2
fi
```

### Option B — hyperfine (script / CLI benchmarks)

```bash
if command -v hyperfine >/dev/null 2>&1; then
  MEAN_MS=$(hyperfine --warmup 3 --runs 10 --export-json /tmp/forge_hf.json \
    "node dist/cli.js --bench" 2>/dev/null \
    && node -p "JSON.parse(require('fs').readFileSync('/tmp/forge_hf.json','utf8')).results[0].mean * 1000" \
    || echo 0)
  PERF_SCORE=$(node -p "Math.max(3.0, parseFloat((10.0 - Math.max(0, $MEAN_MS - 50) / 50.0).toFixed(2)))")
else
  echo "FORGE_EVAL_WARN: hyperfine not found; PERF_SCORE left at default" >&2
fi
```

### Option C — Jest benchmark (unit-level)

If using `jest-bench` or `@jest/globals` with timing:

```bash
if node -e "require('@codspeed/jest')" 2>/dev/null; then
  # Parse Jest JSON output for timing — project-specific
  echo "FORGE_EVAL_WARN: Jest benchmark integration is project-specific; implement manually" >&2
fi
```

---

## Go stack

### Option A — go test -bench (built-in, recommended)

No extra install required.

```bash
# PERF_SCORE via go test -bench (ns/op from BenchmarkHotPath)
BENCH_FUNC="${FORGE_BENCH_FUNC:-BenchmarkHotPath}"   # set FORGE_BENCH_FUNC in env to override
BENCH_OUT=$(go test ./... -bench="^${BENCH_FUNC}$" -benchtime=3s -count=3 2>/dev/null || echo "")
if [[ -n "$BENCH_OUT" ]]; then
  NS_OP=$(echo "$BENCH_OUT" | grep "^Benchmark" | awk '{print $3}' | sort -n | head -1 | sed 's/ns\/op//')
  if [[ -n "$NS_OP" && "$NS_OP" -gt 0 ]]; then
    # 10.0 at ≤ 100ns, 5.0 at 10µs, 2.0 at 1ms — calibrate per project
    PERF_SCORE=$(awk -v ns="$NS_OP" 'BEGIN{
      if(ns<=100)       s=10.0
      else if(ns<=1000) s=10.0-(ns-100)/900.0*3.0
      else if(ns<=10000)s=7.0-(ns-1000)/9000.0*2.0
      else              s=max(2.0, 5.0-(ns-10000)/90000.0*3.0)
      printf "%.2f", s
    }')
  else
    echo "FORGE_EVAL_WARN: go bench output not parseable; PERF_SCORE left at default" >&2
  fi
else
  echo "FORGE_EVAL_WARN: no bench target '${BENCH_FUNC}' found; add benchmarks or set FORGE_BENCH_FUNC" >&2
fi
```

### Option B — hyperfine (binary benchmarks)

```bash
if command -v hyperfine >/dev/null 2>&1; then
  go build -o /tmp/forge_bench_bin ./cmd/myapp 2>/dev/null
  MEAN_MS=$(hyperfine --warmup 5 --runs 20 --export-json /tmp/forge_hf.json \
    "/tmp/forge_bench_bin --bench" 2>/dev/null \
    && python3 -c "import json; d=json.load(open('/tmp/forge_hf.json')); print(d['results'][0]['mean']*1000)" \
    || echo 0)
  PERF_SCORE=$(awk -v ms="$MEAN_MS" 'BEGIN{v=10.0-ms/50.0; if(v<3.0)v=3.0; printf "%.2f",v}')
  rm -f /tmp/forge_bench_bin /tmp/forge_hf.json
fi
```

---

## Calibrating thresholds

The scoring formulas above use example thresholds. **You must calibrate them for your
project** before the first cycle:

1. Run your benchmark at the current baseline and note the raw value (ms, ns/op, rps).
2. Assign that value a score of **5.0** (neutral baseline).
3. Define what "10x better" means and assign score **9.0**.
4. Define "10x worse" and assign score **2.0**.
5. Use linear or log interpolation between those anchors.
6. Record the calibration in `FORGE_SYSTEM.md` under **Scorecard rationale**.

Example:
```
Baseline: 250ms p99 → score 5.0
Target (2× faster): 125ms → score 7.0
Danger (5× slower): 1250ms → score 3.0
Formula: PERF_SCORE = max(2.0, min(10.0, 5.0 - (measured_ms - 250) / 100))
```

---

## Anti-gaming reminder

After wiring PERF_SCORE, verify the harness is not gameable:
- Changing comments or whitespace must not alter PERF_SCORE.
- Re-run EVAL.sh × 3 on the **same commit** to confirm variance ≤ 0.3.
- Document the benchmark target and threshold formula in `FORGE_SYSTEM.md`.

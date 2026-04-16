#!/usr/bin/env bash
# Node-oriented Forge evaluator — starter template.
#
# PERF_SCORE: vitest bench (benchmark.js) → ops/sec mapped to 0–10.
#             Falls back to hyperfine if FORGE_BENCH_CMD is set in FORGE_IDENTITY.md.
#             Falls back to 6.0 placeholder if neither is configured.
#             See docs/EVAL_BENCHMARKS.md for details.
# QUAL_SCORE: eslint general linting (0 warnings → 9.0; any warnings → 3.0).
# TEST_SCORE: npm test — requires a "test" script in package.json (CI=true suppresses watches).
# DEBT_SCORE: eslint complexity rule — counts functions with cyclomatic complexity > 10.
#
# Agents must NOT edit this file during hypothesis cycles (write-protected by CLAUDE.md Rule 1).
# Human maintainers may edit for adoption, stack upgrades, or harness repair only.
set -euo pipefail

EXIT=0
export CI=true

PERF_SCORE=6.0   # default placeholder; overridden below if benchmark tools are present
QUAL_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once eslint runs
TEST_SCORE=5.0   # 5.0 = not yet measured; rises to 0.0 or 10.0 once npm test runs
DEBT_SCORE=5.0   # 5.0 = not yet measured; rises to 3.0–9.0 once eslint complexity runs

# Read optional FORGE_BENCH_CMD from FORGE_IDENTITY.md (hyperfine fallback)
FORGE_BENCH_CMD=""
if [[ -f FORGE_IDENTITY.md ]]; then
  FORGE_BENCH_CMD=$(grep -i 'FORGE_BENCH_CMD' FORGE_IDENTITY.md | head -1 | sed 's/.*: *//' | tr -d '"' || true)
fi

# ── Runtime check ──────────────────────────────────────────────────────────────
if ! command -v node >/dev/null 2>&1; then
  echo "FORGE_EVAL_ERR: node not found" >&2
  printf "PERF_SCORE: 0.0\nQUAL_SCORE: 0.0\nTEST_SCORE: 0.0\nDEBT_SCORE: 0.0\nSCORE: 0.0\n"
  exit 2
fi

# ── PERF_SCORE ─────────────────────────────────────────────────────────────────
HF_JSON_FILE="/tmp/forge_hf_$$.json"

# Strategy 1: vitest bench (benchmark.js in repo root)
if [[ -f benchmark.js ]] && command -v npx >/dev/null 2>&1; then
  VITEST_OUT_FILE="/tmp/forge_vitest_$$.json"
  set +e
  npx --yes vitest bench benchmark.js --reporter=json --outputFile="$VITEST_OUT_FILE" \
    >/dev/null 2>&1
  VITEST_EXIT=$?
  set -e
  if [[ $VITEST_EXIT -eq 0 && -f "$VITEST_OUT_FILE" ]]; then
    PERF_SCORE=$(FORGE_VITEST_OUT="$VITEST_OUT_FILE" node - <<'JS'
const fs = require("fs");
try {
  const data = JSON.parse(fs.readFileSync(process.env.FORGE_VITEST_OUT, "utf8"));
  const hzValues = [];
  (data.testResults || []).forEach(r =>
    (r.benchmarkResults || []).forEach(b => { if (b.hz) hzValues.push(b.hz); })
  );
  if (!hzValues.length) { process.stdout.write("6.0\n"); process.exit(); }
  const sorted = hzValues.slice().sort((a, b) => a - b);
  const medHz = sorted[Math.floor(sorted.length / 2)];
  // log10 scale: 100 ops/s→2.0, 10k→4.0, 1M→8.0 (capped 0–10)
  const score = Math.min(10, Math.max(0, (Math.log10(Math.max(1, medHz)) - 2) * 2));
  process.stdout.write(score.toFixed(2) + "\n");
} catch (e) { process.stdout.write("6.0\n"); }
JS
) || PERF_SCORE=6.0
    rm -f "$VITEST_OUT_FILE"
  else
    echo "FORGE_EVAL_WARN: vitest bench failed; trying hyperfine" >&2
    rm -f "$VITEST_OUT_FILE" 2>/dev/null || true
  fi
fi

# Strategy 2: hyperfine (FORGE_BENCH_CMD set in FORGE_IDENTITY.md)
if [[ "$PERF_SCORE" == "6.0" && -n "$FORGE_BENCH_CMD" ]] && command -v hyperfine >/dev/null 2>&1; then
  set +e
  hyperfine --runs 5 --export-json "$HF_JSON_FILE" "$FORGE_BENCH_CMD" >/dev/null 2>&1
  HF_EXIT=$?
  set -e
  if [[ $HF_EXIT -eq 0 && -f "$HF_JSON_FILE" ]]; then
    PERF_SCORE=$(FORGE_HF_JSON="$HF_JSON_FILE" node - <<'JS'
const fs = require("fs");
try {
  const data = JSON.parse(fs.readFileSync(process.env.FORGE_HF_JSON, "utf8"));
  const medianS = data.results[0].median;
  const score = Math.max(0, Math.min(10, 10 - Math.log10(Math.max(0.001, medianS)) * 2.5));
  process.stdout.write(score.toFixed(2) + "\n");
} catch (e) { process.stdout.write("6.0\n"); }
JS
) || PERF_SCORE=6.0
    rm -f "$HF_JSON_FILE"
  else
    echo "FORGE_EVAL_WARN: hyperfine failed; PERF_SCORE left at placeholder" >&2
  fi
elif [[ "$PERF_SCORE" == "6.0" ]]; then
  echo "FORGE_EVAL_WARN: no benchmark configured (no benchmark.js, no FORGE_BENCH_CMD); PERF_SCORE=6.0 placeholder — see docs/EVAL_BENCHMARKS.md" >&2
fi

# ── TEST_SCORE ─────────────────────────────────────────────────────────────────
if [[ -f package.json ]]; then
  if node -e "const p=require('./package.json');process.exit(p.scripts&&p.scripts.test?0:1)" 2>/dev/null; then
    set +e
    npm test --silent 2>/dev/null
    NPM_EXIT=$?
    set -e
    if [[ $NPM_EXIT -eq 0 ]]; then
      TEST_SCORE=10.0
    else
      TEST_SCORE=0.0
      EXIT=1
    fi
  else
    echo "FORGE_EVAL_WARN: package.json has no 'test' script; TEST_SCORE left at default" >&2
  fi
else
  echo "FORGE_EVAL_WARN: no package.json found; TEST_SCORE left at default" >&2
fi

# ── ESLint config detection (used by both QUAL and DEBT) ─────────────────────
HAS_ESLINT_CFG=false
for _f in eslint.config.js eslint.config.mjs eslint.config.cjs \
           .eslintrc.js .eslintrc.cjs .eslintrc.json .eslintrc.yaml .eslintrc.yml; do
  [[ -f "$_f" ]] && { HAS_ESLINT_CFG=true; break; }
done

# ── QUAL_SCORE ─────────────────────────────────────────────────────────────────
if command -v eslint >/dev/null 2>&1 && [[ "$HAS_ESLINT_CFG" == "true" ]]; then
  if eslint . --max-warnings=0 >/dev/null 2>&1; then
    QUAL_SCORE=9.0
  else
    QUAL_SCORE=3.0
  fi
else
  echo "FORGE_EVAL_WARN: eslint not found or no config; QUAL_SCORE left at default" >&2
fi

# ── DEBT_SCORE ─────────────────────────────────────────────────────────────────
if command -v eslint >/dev/null 2>&1 && [[ "$HAS_ESLINT_CFG" == "true" ]]; then
  COMPLEX_VIOLATIONS=$(eslint . --rule 'complexity: ["warn", 10]' --format compact 2>/dev/null \
    | grep -c "complexity" 2>/dev/null || echo 0)
  if [[ "$COMPLEX_VIOLATIONS" -eq 0 ]]; then
    DEBT_SCORE=9.0
  else
    DEBT_SCORE=$(node -p "Math.max(3.0, parseFloat((10.0 - ${COMPLEX_VIOLATIONS} * 0.35).toFixed(2)))")
  fi
else
  echo "FORGE_EVAL_WARN: eslint not available for complexity scan; DEBT_SCORE left at default" >&2
fi

# ── Composite SCORE ────────────────────────────────────────────────────────────
SCORE=$(node -p "parseFloat((0.20*${PERF_SCORE}+0.25*${QUAL_SCORE}+0.35*${TEST_SCORE}+0.20*${DEBT_SCORE}).toFixed(2))")

echo "PERF_SCORE: ${PERF_SCORE}"
echo "QUAL_SCORE: ${QUAL_SCORE}"
echo "TEST_SCORE: ${TEST_SCORE}"
echo "DEBT_SCORE: ${DEBT_SCORE}"
echo "SCORE: ${SCORE}"
exit "$EXIT"

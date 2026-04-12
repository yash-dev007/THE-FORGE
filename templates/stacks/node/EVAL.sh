#!/usr/bin/env bash
# Node-oriented Forge evaluator — starter template.
#
# PERF_SCORE: static placeholder (6.0) — wire a real benchmark per your project.
#             See docs/CUSTOMIZING_EVAL.md for autocannon, hyperfine, and Jest options.
# QUAL_SCORE: eslint general linting (0 warnings → 9.0; any warnings → 3.0).
# TEST_SCORE: npm test — requires a "test" script in package.json (CI=true suppresses watches).
# DEBT_SCORE: eslint complexity rule — counts functions with cyclomatic complexity > 10.
#             10+ violations reduce score from 9.0 toward 3.0. Needs eslint on PATH.
#
# Agents must NOT edit this file during hypothesis cycles (write-protected by CLAUDE.md Rule 1).
# Human maintainers may edit for adoption, stack upgrades, or harness repair only.
set -euo pipefail

EXIT=0
export CI=true

# PERF_SCORE: replace this line with a benchmark integration (see docs/CUSTOMIZING_EVAL.md).
PERF_SCORE=6.0
QUAL_SCORE=6.0
TEST_SCORE=5.0
DEBT_SCORE=6.0

# ── Runtime check ──────────────────────────────────────────────────────────────
if ! command -v node >/dev/null 2>&1; then
  echo "FORGE_EVAL_ERR: node not found" >&2
  printf "PERF_SCORE: 0.0\nQUAL_SCORE: 0.0\nTEST_SCORE: 0.0\nDEBT_SCORE: 0.0\nSCORE: 0.0\n"
  exit 2
fi

# ── TEST_SCORE ─────────────────────────────────────────────────────────────────
if [[ -f package.json ]]; then
  if node -e "const p=require('./package.json');process.exit(p.scripts&&p.scripts.test?0:1)" 2>/dev/null; then
    if npm test --silent 2>/dev/null; then
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

# ── QUAL_SCORE — general linting ───────────────────────────────────────────────
if command -v eslint >/dev/null 2>&1 && [[ "$HAS_ESLINT_CFG" == "true" ]]; then
  if eslint . --max-warnings=0 >/dev/null 2>&1; then
    QUAL_SCORE=9.0
  else
    QUAL_SCORE=3.0
  fi
else
  echo "FORGE_EVAL_WARN: eslint not found or no config; QUAL_SCORE left at default" >&2
fi

# ── DEBT_SCORE — cyclomatic complexity scan ───────────────────────────────────
# Counts functions where CC > 10 using eslint's built-in complexity rule.
# Score: 0 violations → 9.0; each violation subtracts 0.35 (floor 3.0).
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

# ── SCORE composite ────────────────────────────────────────────────────────────
SCORE=$(node -p "parseFloat((0.20*${PERF_SCORE}+0.25*${QUAL_SCORE}+0.35*${TEST_SCORE}+0.20*${DEBT_SCORE}).toFixed(2))")

echo "PERF_SCORE: ${PERF_SCORE}"
echo "QUAL_SCORE: ${QUAL_SCORE}"
echo "TEST_SCORE: ${TEST_SCORE}"
echo "DEBT_SCORE: ${DEBT_SCORE}"
echo "SCORE: ${SCORE}"
exit "$EXIT"

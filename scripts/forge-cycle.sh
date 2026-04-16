#!/usr/bin/env bash
# forge-cycle.sh — THE FORGE v4 loop driver (core logic)
# Copied to adopted repos by forge-adopt.sh. Run from repo root.
#
# Usage:
#   bash ./forge-cycle.sh                  # Full interactive cycle
#   bash ./forge-cycle.sh --baseline-only  # Run baseline only (for AI skill integration)
#   bash ./forge-cycle.sh --skip-baseline SCORE  # Evaluate against existing SCORE
#
# This script handles all mechanical steps. AI hypothesis generation is handled
# by platform wrappers (forge-cycle.md skill, GEMINI.md, etc.) which call this script.
set -euo pipefail

# ── Argument parsing ────────────────────────────────────────────────────────
MODE="full"
EXISTING_BASELINE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --baseline-only) MODE="baseline"; shift ;;
    --skip-baseline) MODE="evaluate"; EXISTING_BASELINE="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--baseline-only] [--skip-baseline SCORE]"
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

# ── Helpers ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YEL='\033[1;33m'; GRN='\033[0;32m'; BLU='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLU}[FORGE]${NC} $*"; }
warn()  { echo -e "${YEL}[FORGE] WARN:${NC} $*"; }
block() { echo -e "${RED}[FORGE] BLOCKED — $*${NC}"; exit 1; }
ok()    { echo -e "${GRN}[FORGE]${NC} $*"; }

# Extract a section body from a markdown file (text after "## Section" until next "##")
extract_section() {
  local file="$1" section="$2"
  awk "/^## ${section}/{found=1; next} found && /^## /{exit} found{print}" "$file" \
    | sed '/^$/d' | head -5
}

# Compute median of three numbers (awk)
median3() {
  awk -v a="$1" -v b="$2" -v c="$3" '
    BEGIN {
      if (a > b) { t=a; a=b; b=t }
      if (b > c) { t=b; b=c; c=t }
      if (a > b) { t=a; a=b; b=t }
      printf "%.2f", b
    }'
}

# Run EVAL.sh three times, return median composite SCORE and all sub-scores
run_eval_triple() {
  local label="$1"
  info "Running EVAL.sh × 3 ($label)..."

  local scores=() perfs=() quals=() tests=() debts=()
  for i in 1 2 3; do
    echo -n "  Run $i/3 ... "
    set +e
    local output
    output=$(bash ./EVAL.sh 2>/dev/null)
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 2 ]]; then
      warn "EVAL.sh exited with code 2 (environment error). Fix env before cycling."
      exit 2
    fi

    local s p q t d
    s=$(echo "$output" | grep '^SCORE:'     | awk '{print $2}')
    p=$(echo "$output" | grep '^PERF_SCORE:' | awk '{print $2}')
    q=$(echo "$output" | grep '^QUAL_SCORE:' | awk '{print $2}')
    t=$(echo "$output" | grep '^TEST_SCORE:' | awk '{print $2}')
    d=$(echo "$output" | grep '^DEBT_SCORE:' | awk '{print $2}')

    scores+=("${s:-0}"); perfs+=("${p:-0}"); quals+=("${q:-0}")
    tests+=("${t:-0}"); debts+=("${d:-0}")
    echo "SCORE=${s:-ERR}"
  done

  SCORE=$(median3 "${scores[0]}" "${scores[1]}" "${scores[2]}")
  PERF_SCORE=$(median3  "${perfs[0]}"  "${perfs[1]}"  "${perfs[2]}")
  QUAL_SCORE=$(median3  "${quals[0]}"  "${quals[1]}"  "${quals[2]}")
  TEST_SCORE=$(median3  "${tests[0]}"  "${tests[1]}"  "${tests[2]}")
  DEBT_SCORE=$(median3  "${debts[0]}"  "${debts[1]}"  "${debts[2]}")

  local spread
  spread=$(awk -v a="${scores[0]}" -v b="${scores[1]}" -v c="${scores[2]}" '
    BEGIN {
      mn = a < b ? a : b; mn = mn < c ? mn : c
      mx = a > b ? a : b; mx = mx > c ? mx : c
      printf "%.2f", mx - mn
    }')

  if awk -v s="$spread" 'BEGIN{exit (s > 0.3)}'; then
    : # variance OK
  else
    warn "EVAL.sh variance > 0.3 (spread=${spread}) — harness may be flaky."
    warn "Human must investigate EVAL.sh before cycling. Results below are unreliable."
  fi

  info "Median scores: PERF=${PERF_SCORE} QUAL=${QUAL_SCORE} TEST=${TEST_SCORE} DEBT=${DEBT_SCORE} → COMPOSITE=${SCORE}"
}

# ── Step 1: Read FORGE_IDENTITY.md ───────────────────────────────────────────
[[ -f FORGE_IDENTITY.md ]] || block "Reason: FORGE_IDENTITY.md missing | Needs: run forge-adopt or see THE FORGE kit docs/ADOPT.md"

SLUG=$(grep -i 'ForgeProjectSlug' FORGE_IDENTITY.md | head -1 | sed 's/.*: *//' | tr -d '[:space:]')
OBS_ROOT=$(grep -i 'ObsidianVaultRoot' FORGE_IDENTITY.md | head -1 | sed 's/.*: *//' | tr -d '[:space:]')

[[ -n "$SLUG" ]] || block "Reason: ForgeProjectSlug not set in FORGE_IDENTITY.md"
info "Project: ${SLUG}"

# ── Step 2: Read + validate RESEARCH.md ─────────────────────────────────────
[[ -f RESEARCH.md ]] || block "Reason: RESEARCH.md missing"

validate_field() {
  local file="$1" section="$2"
  local content
  content=$(extract_section "$file" "$section")
  if [[ -z "$content" ]] || echo "$content" | grep -qiE '^\s*(One falsifiable|Exactly one of|Fill \*\*after|Max cycles|Must be greater|List failed)'; then
    block "Reason: RESEARCH.md incomplete — '## ${section}' is blank or placeholder"
  fi
}

REQUIRED_SECTIONS=("Hypothesis" "Hypothesis Type" "Confidence" "Target File" "Target Scope" "Baseline Score" "Goal Score" "Exploration Budget")
for section in "${REQUIRED_SECTIONS[@]}"; do
  validate_field RESEARCH.md "$section"
done

HYPOTHESIS=$(extract_section RESEARCH.md "Hypothesis" | head -1)
HYPO_TYPE=$(extract_section RESEARCH.md "Hypothesis Type" | head -1)
BASELINE_IN_FILE=$(extract_section RESEARCH.md "Baseline Score" | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "")
GOAL_SCORE=$(extract_section RESEARCH.md "Goal Score" | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "")

info "Hypothesis: ${HYPOTHESIS}"
info "Type: ${HYPO_TYPE}"

# ── Step 3: Baseline EVAL ────────────────────────────────────────────────────
[[ -f EVAL.sh ]] || block "Reason: EVAL.sh missing — run forge-adopt first"

if [[ "$MODE" == "evaluate" ]]; then
  # Skip baseline, use provided score
  BASELINE_SCORE="$EXISTING_BASELINE"
  info "Using provided baseline: ${BASELINE_SCORE}"
  BASELINE_PERF="?"; BASELINE_QUAL="?"; BASELINE_TEST="?"; BASELINE_DEBT="?"
else
  run_eval_triple "baseline"
  BASELINE_SCORE="$SCORE"
  BASELINE_PERF="$PERF_SCORE"; BASELINE_QUAL="$QUAL_SCORE"
  BASELINE_TEST="$TEST_SCORE"; BASELINE_DEBT="$DEBT_SCORE"
fi

# ── Step 4: Forge Status Report ──────────────────────────────────────────────
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  FORGE STATUS REPORT — ${SLUG} — ${TIMESTAMP}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Hypothesis: ${HYPOTHESIS}"
echo "  Type:       ${HYPO_TYPE}"
echo "  Baseline:   ${BASELINE_SCORE}  (goal: ${GOAL_SCORE:-?})"
echo ""
echo "  Sub-scores  PERF=${BASELINE_PERF}  QUAL=${BASELINE_QUAL}  TEST=${BASELINE_TEST}  DEBT=${BASELINE_DEBT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Exit here if baseline-only mode (AI platform handles hypothesis generation)
if [[ "$MODE" == "baseline" ]]; then
  info "Baseline complete. AI platform: generate 3 hypotheses ranked by P(success), wait for human selection."
  info "After implementation, run: bash ./forge-cycle.sh --skip-baseline ${BASELINE_SCORE}"
  exit 0
fi

# ── Step 5: Wait for human to implement ─────────────────────────────────────
echo ""
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │  Implement your hypothesis now.                         │"
echo "  │  When done, press ENTER to run post-implementation eval │"
echo "  └─────────────────────────────────────────────────────────┘"
echo ""
read -r -p "  Press ENTER when implementation is complete..."
echo ""

# ── Step 6: Post-implementation EVAL ────────────────────────────────────────
run_eval_triple "post-implementation"
NEW_SCORE="$SCORE"
NEW_PERF="$PERF_SCORE"; NEW_QUAL="$QUAL_SCORE"
NEW_TEST="$TEST_SCORE"; NEW_DEBT="$DEBT_SCORE"

# ── Step 7: Anti-gaming rules ────────────────────────────────────────────────
# Flag anomalous sub-score jumps that inflate composite without real improvement
ANOMALY=""

check_subscore_jump() {
  local name="$1" old="$2" new="$3" threshold="${4:-3.0}"
  local delta
  delta=$(awk -v n="$new" -v o="$old" 'BEGIN{printf "%.2f", n - o}')
  local abs_delta
  abs_delta=$(awk -v d="$delta" 'BEGIN{printf "%.2f", d < 0 ? -d : d}')
  if awk -v a="$abs_delta" -v t="$threshold" 'BEGIN{exit !(a > t)}'; then
    ANOMALY="${ANOMALY}${name}:${old}→${new}(Δ${delta}) "
  fi
}

if [[ "$BASELINE_PERF" != "?" ]]; then
  check_subscore_jump "PERF" "$BASELINE_PERF" "$NEW_PERF"
  check_subscore_jump "QUAL" "$BASELINE_QUAL" "$NEW_QUAL"
  check_subscore_jump "TEST" "$BASELINE_TEST" "$NEW_TEST"
  check_subscore_jump "DEBT" "$BASELINE_DEBT" "$NEW_DEBT"
fi

# ── Step 8: Decision ─────────────────────────────────────────────────────────
DELTA=$(awk -v n="$NEW_SCORE" -v b="$BASELINE_SCORE" 'BEGIN{printf "%.2f", n - b}')
DECISION=""

if [[ -n "$ANOMALY" ]]; then
  DECISION="ANOMALY"
else
  if awk -v n="$NEW_SCORE" -v b="$BASELINE_SCORE" 'BEGIN{exit !(n > b + 0.1)}'; then
    DECISION="COMMIT"
  elif awk -v n="$NEW_SCORE" -v b="$BASELINE_SCORE" 'BEGIN{exit !(n < b - 0.1)}'; then
    DECISION="REVERT"
  else
    DECISION="HOLD"
  fi
fi

# Print result
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RESULT"
echo "  Score:    ${BASELINE_SCORE} → ${NEW_SCORE}  (Δ ${DELTA})"
echo "  Sub:      PERF=${NEW_PERF}  QUAL=${NEW_QUAL}  TEST=${NEW_TEST}  DEBT=${NEW_DEBT}"
if [[ -n "$ANOMALY" ]]; then
  echo -e "  ${RED}[FORGE] ANOMALY DETECTED — sub-score spike: ${ANOMALY}${NC}"
  echo "  Action: revert changes and investigate the harness before cycling."
else
  case "$DECISION" in
    COMMIT) echo -e "  ${GRN}Decision: COMMIT — improvement confirmed${NC}" ;;
    REVERT) echo -e "  ${RED}Decision: REVERT — score regressed${NC}" ;;
    HOLD)   echo -e "  ${YEL}Decision: HOLD — no significant change${NC}" ;;
  esac
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Step 9: Write to PROJECT_LOG.md ─────────────────────────────────────────
ISO_DATE=$(date -u +"%Y-%m-%d")

# Find next cycle number
NEXT_CYCLE=1
if [[ -f PROJECT_LOG.md ]]; then
  LAST_CYCLE=$(grep -oE '^## Cycle ([0-9]+)' PROJECT_LOG.md | tail -1 | grep -oE '[0-9]+' || echo 0)
  NEXT_CYCLE=$((LAST_CYCLE + 1))
fi

TARGET_FILE_LOG=$(extract_section RESEARCH.md "Target File" | head -1)
TARGET_SCOPE_LOG=$(extract_section RESEARCH.md "Target Scope" | head -1)

CYCLE_ENTRY="
## Cycle ${NEXT_CYCLE} — ${ISO_DATE} — ${HYPO_TYPE}

| Field | Value |
|-------|-------|
| Hypothesis | ${HYPOTHESIS} |
| Target File | ${TARGET_FILE_LOG:-?} |
| Mechanism | (fill in) |
| Predicted Δ | (fill in) |
| Actual Δ | ${DELTA} |
| Prediction accuracy | (fill in) |
| Scores | PERF: ${BASELINE_PERF}→${NEW_PERF} · QUAL: ${BASELINE_QUAL}→${NEW_QUAL} · TEST: ${BASELINE_TEST}→${NEW_TEST} · DEBT: ${BASELINE_DEBT}→${NEW_DEBT} · COMPOSITE: ${BASELINE_SCORE}→${NEW_SCORE} |
| Decision | ${DECISION} |
| Anomalies | ${ANOMALY:-None} |

**Causal Explanation:**
(fill in — what mechanism drove the change?)

**Negative Knowledge:**
(fill in — what did NOT work?)

**Pattern Signal:**
(fill in — worth promoting to Forge/Patterns/ ?)
"

if [[ -f PROJECT_LOG.md ]]; then
  echo "$CYCLE_ENTRY" >> PROJECT_LOG.md
  ok "Cycle ${NEXT_CYCLE} appended to PROJECT_LOG.md"
else
  warn "PROJECT_LOG.md not found — cycle entry printed below:"
  echo "$CYCLE_ENTRY"
fi

# ── Step 10: Obsidian sync ────────────────────────────────────────────────────
if [[ -f forge-obsidian-sync.sh ]]; then
  bash ./forge-obsidian-sync.sh \
    --slug "$SLUG" \
    --obs-root "${OBS_ROOT:-}" \
    --cycle "$NEXT_CYCLE" \
    --baseline "$BASELINE_SCORE" \
    --new-score "$NEW_SCORE" \
    --delta "$DELTA" \
    --decision "$DECISION" \
    --hypothesis "$HYPOTHESIS" \
    --date "$ISO_DATE" \
    || warn "forge-obsidian-sync.sh failed — Obsidian not updated"
else
  warn "forge-obsidian-sync.sh not found — Obsidian sync skipped"
fi

# ── Step 11: Next action ─────────────────────────────────────────────────────
echo ""
info "Next action:"
case "$DECISION" in
  COMMIT)
    echo "  → git commit the changes with a descriptive message"
    echo "  → Fill in 'Causal Explanation' and 'Pattern Signal' in PROJECT_LOG.md"
    echo "  → Update RESEARCH.md Baseline Score to ${NEW_SCORE}"
    echo "  → Run forge-cycle.sh again for the next hypothesis"
    ;;
  REVERT)
    echo "  → git checkout -- . (revert all changes)"
    echo "  → Update RESEARCH.md > Blocked Approaches with what failed"
    echo "  → Run forge-cycle.sh again with a different hypothesis"
    ;;
  HOLD)
    echo "  → Consider: is the hypothesis falsifiable? Is the target scope wide enough?"
    echo "  → Optionally extend scope and re-run, or pivot hypothesis"
    ;;
  ANOMALY)
    echo "  → git checkout -- . (revert all changes)"
    echo "  → Investigate EVAL.sh for gaming vectors (see docs/EVAL_BENCHMARKS.md)"
    echo "  → DO NOT commit until anomaly is resolved"
    ;;
esac
echo ""

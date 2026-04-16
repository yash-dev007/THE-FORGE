#!/usr/bin/env bash
# forge-obsidian-sync.sh — THE FORGE v4 Obsidian write helper
# Called at end of every cycle by forge-cycle.sh.
# Copied to adopted repos by forge-adopt.sh.
#
# Usage (called internally by forge-cycle.sh):
#   bash ./forge-obsidian-sync.sh \
#     --slug PROJECT \
#     --obs-root /path/to/vault \
#     --cycle N \
#     --baseline 6.5 --new-score 7.2 --delta 0.7 \
#     --decision COMMIT \
#     --hypothesis "Replacing X with Y reduces latency" \
#     --date 2026-04-15
set -euo pipefail

# ── Argument parsing ────────────────────────────────────────────────────────
SLUG=""; OBS_ROOT=""; CYCLE=""; BASELINE=""
NEW_SCORE=""; DELTA=""; DECISION=""; HYPOTHESIS=""; DATE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)       SLUG="$2";       shift 2 ;;
    --obs-root)   OBS_ROOT="$2";   shift 2 ;;
    --cycle)      CYCLE="$2";      shift 2 ;;
    --baseline)   BASELINE="$2";   shift 2 ;;
    --new-score)  NEW_SCORE="$2";  shift 2 ;;
    --delta)      DELTA="$2";      shift 2 ;;
    --decision)   DECISION="$2";   shift 2 ;;
    --hypothesis) HYPOTHESIS="$2"; shift 2 ;;
    --date)       DATE="$2";       shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

# ── Guard: skip if ObsidianVaultRoot not set ──────────────────────────────────
if [[ -z "$OBS_ROOT" ]]; then
  echo "[FORGE] WARN: ObsidianVaultRoot not set — Obsidian sync skipped" >&2
  exit 0
fi

if [[ ! -d "$OBS_ROOT" ]]; then
  echo "[FORGE] WARN: ObsidianVaultRoot not a directory: ${OBS_ROOT} — sync skipped" >&2
  exit 0
fi

PROJECT_DIR="${OBS_ROOT}/Forge/Projects/${SLUG}"

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "[FORGE] WARN: Project dir not found: ${PROJECT_DIR} — sync skipped" >&2
  echo "  Create it manually: see docs/OBSIDIAN_SETUP.md" >&2
  exit 0
fi

# ── Step 3: Append cycle to 01-Score-History.md ──────────────────────────────
HISTORY_FILE="${PROJECT_DIR}/01-Score-History.md"

# Decision badge
case "$DECISION" in
  COMMIT)  BADGE="✅ COMMIT" ;;
  REVERT)  BADGE="❌ REVERT" ;;
  HOLD)    BADGE="⏸ HOLD"   ;;
  ANOMALY) BADGE="⚠️ ANOMALY" ;;
  *)       BADGE="$DECISION"  ;;
esac

HISTORY_LINE="| ${DATE} | ${CYCLE} | ${BASELINE} | ${NEW_SCORE} | ${DELTA} | ${BADGE} | ${HYPOTHESIS} |"

if [[ -f "$HISTORY_FILE" ]]; then
  echo "$HISTORY_LINE" >> "$HISTORY_FILE"
else
  # Create file with header
  cat > "$HISTORY_FILE" <<EOF
# Score History — ${SLUG}

| Date | Cycle | Baseline | New Score | Δ | Decision | Hypothesis |
|------|-------|----------|-----------|---|----------|------------|
${HISTORY_LINE}
EOF
fi

echo "[FORGE] Score History updated: ${HISTORY_FILE}"

# ── Step 4: Update 00-Project-Index.md ─────────────────────────────────────
INDEX_FILE="${PROJECT_DIR}/00-Project-Index.md"

if [[ -f "$INDEX_FILE" ]]; then
  # Update or insert tracking metrics
  TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")
  WINS=$(grep -c 'COMMIT' "$HISTORY_FILE" 2>/dev/null || echo 0)
  TOTAL=$(grep -cE '^\|' "$HISTORY_FILE" 2>/dev/null | awk '{print $1 - 1}' || echo 0)

  # Remove existing auto-updated block if present, then append fresh one
  if grep -q '<!-- forge-auto -->' "$INDEX_FILE"; then
    # Remove old auto block
    sed -i '/<!-- forge-auto -->/,/<!-- \/forge-auto -->/d' "$INDEX_FILE"
  fi

  cat >> "$INDEX_FILE" <<EOF

<!-- forge-auto -->
## Forge Metrics (auto-updated)

| Field | Value |
|-------|-------|
| Last cycle | ${CYCLE} |
| Last score | ${NEW_SCORE} |
| Last decision | ${BADGE} |
| Win rate | ${WINS} / ${TOTAL} |
| Last updated | ${TIMESTAMP} |
<!-- /forge-auto -->
EOF
  echo "[FORGE] Project Index updated: ${INDEX_FILE}"
fi

# ── Step 5: Pattern candidate detection ──────────────────────────────────────
# Check if DECISION=COMMIT appeared for the same hypothesis mechanism in ≥ 2 cycles.
# We do a simplified heuristic: look for repeated hypothesis keywords in COMMIT rows.

if [[ "$DECISION" == "COMMIT" && -f "$HISTORY_FILE" ]]; then
  # Extract first 4 words of hypothesis as a key
  KEY=$(echo "$HYPOTHESIS" | awk '{print tolower($1" "$2" "$3" "$4)}')
  OCCURRENCES=$(grep -i "COMMIT" "$HISTORY_FILE" | grep -ic "$KEY" 2>/dev/null || echo 0)

  if [[ "$OCCURRENCES" -ge 2 ]]; then
    echo ""
    echo "[FORGE] PATTERN CANDIDATE — this mechanism has COMMIT-ed ≥ 2 times:"
    echo "  Hypothesis pattern: '${KEY}...'"
    echo "  Review and promote manually: ${OBS_ROOT}/Forge/Patterns/"
    echo "  Template: ${OBS_ROOT}/Forge/Patterns/_example-performance-pattern.md"
  fi
fi

echo "[FORGE] Obsidian sync complete."

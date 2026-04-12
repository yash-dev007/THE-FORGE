#!/usr/bin/env bash
# Refresh THE FORGE methodology templates in an already-adopted repository.
#
# Copies:
#   templates/universal/CLAUDE.md  → <target>/CLAUDE.md
#   templates/claude-code/         → <target>/.claude/  (CLAUDE.md + settings.json)
#   templates/cursor/forge-v3.mdc  → <target>/.cursor/rules/forge-v3.mdc
#
# Does NOT overwrite project state:
#   FORGE_IDENTITY.md, RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md
#
# Use --update-eval to also refresh EVAL.sh + EVAL_SPEC.md from the stack template.
# WARNING: updating EVAL.sh resets the scoring baseline — re-run EVAL.sh × 3 and
# record a new median in RESEARCH.md before resuming hypothesis cycles.
set -euo pipefail

STACK=""
TARGET=""
UPDATE_EVAL=false

usage() {
  cat >&2 <<EOF
Usage: $0 --target /path/to/repo [--stack minimal|python|node|go] [--update-eval]

  --target      Path to the already-adopted repository root (required)
  --stack       Stack name (required when --update-eval is set)
  --update-eval Also refresh EVAL.sh + EVAL_SPEC.md (changes the baseline — use carefully)
EOF
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)    TARGET="${2:-}"; shift 2 ;;
    --stack)     STACK="${2:-}";  shift 2 ;;
    --update-eval) UPDATE_EVAL=true; shift ;;
    -h|--help)   usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
done

[[ -n "$TARGET" ]] || { echo "Error: --target is required" >&2; usage; }
[[ -d "$TARGET" ]] || { echo "Error: target not a directory: $TARGET" >&2; exit 2; }

if [[ "$UPDATE_EVAL" == "true" && -z "$STACK" ]]; then
  echo "Error: --stack is required when --update-eval is set" >&2
  usage
fi

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$KIT_ROOT/templates"
U="$T/universal"
CC="$T/claude-code"
CUR="$T/cursor"

# --- Update CLAUDE.md (operating rules) ---
echo "  [update] CLAUDE.md"
cp "$U/CLAUDE.md" "$TARGET/CLAUDE.md"

# --- Update Claude Code integration ---
mkdir -p "$TARGET/.claude"
echo "  [update] .claude/CLAUDE.md"
cp "$CC/CLAUDE.md" "$TARGET/.claude/CLAUDE.md"

# settings.json: copy only if not already customized (check for _comment sentinel)
if [[ ! -f "$TARGET/.claude/settings.json" ]]; then
  echo "  [create] .claude/settings.json (new)"
  cp "$CC/settings.json" "$TARGET/.claude/settings.json"
else
  echo "  [skip]   .claude/settings.json (exists — merge manually if needed)"
fi

# --- Update Cursor rule ---
mkdir -p "$TARGET/.cursor/rules"
echo "  [update] .cursor/rules/forge-v3.mdc"
cp "$CUR/forge-v3.mdc" "$TARGET/.cursor/rules/forge-v3.mdc"

# --- Optionally update EVAL harness ---
if [[ "$UPDATE_EVAL" == "true" ]]; then
  S="$T/stacks/$STACK"
  [[ -d "$S" ]] || { echo "Error: stack not found: $S" >&2; exit 2; }
  echo ""
  echo "  [update] EVAL_SPEC.md + EVAL.sh  *** BASELINE RESET — see warning below ***"
  cp "$S/EVAL_SPEC.md" "$TARGET/EVAL_SPEC.md"
  cp "$S/EVAL.sh"      "$TARGET/EVAL.sh"
  chmod +x "$TARGET/EVAL.sh"
fi

echo ""
echo "Update complete: $TARGET"
echo ""
if [[ "$UPDATE_EVAL" == "true" ]]; then
  echo "  *** EVAL.sh was refreshed. You MUST:"
  echo "      1. Run ./EVAL.sh three times on unchanged code."
  echo "      2. Record the new median in RESEARCH.md > Baseline Score."
  echo "      3. Note the harness change in PROJECT_LOG.md."
  echo "      Hypothesis cycles must not resume until baseline is re-established. ***"
  echo ""
fi
echo "  Files NOT updated (project state — update manually if needed):"
echo "    FORGE_IDENTITY.md, RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md"

#!/usr/bin/env bash
# Refresh THE FORGE methodology templates in an already-adopted repository.
#
# Copies (always):
#   templates/universal/FORGE.md       → <target>/CLAUDE.md
#   templates/claude-code/FORGE_BRIDGE.md → <target>/.claude/CLAUDE.md
#   templates/claude-code/skills/forge-cycle.md → <target>/.claude/skills/forge-cycle.md
#   templates/cursor/forge.mdc         → <target>/.cursor/rules/forge.mdc
#   templates/gemini-cli/GEMINI.md     → <target>/GEMINI.md
#   templates/codex/program.md         → <target>/program.md (if exists)
#   templates/copilot/copilot-instructions.md → <target>/.github/copilot-instructions.md (if exists)
#   scripts/forge-cycle.sh             → <target>/forge-cycle.sh
#   scripts/forge-obsidian-sync.sh     → <target>/forge-obsidian-sync.sh
#   scripts/forge-chart.py             → <target>/forge-chart.py
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
Usage: $0 --target /path/to/repo [--stack minimal|python|node|go|rust] [--update-eval]

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
S_DIR="$KIT_ROOT/scripts"

# --- Update CLAUDE.md (operating rules) ---
echo "  [update] CLAUDE.md"
cp "$U/FORGE.md" "$TARGET/CLAUDE.md"

# --- Update Claude Code integration ---
mkdir -p "$TARGET/.claude/skills"
echo "  [update] .claude/CLAUDE.md"
cp "$CC/FORGE_BRIDGE.md" "$TARGET/.claude/CLAUDE.md"
echo "  [update] .claude/skills/forge-cycle.md"
cp "$CC/skills/forge-cycle.md" "$TARGET/.claude/skills/forge-cycle.md"

# settings.json: copy only if not already present
if [[ ! -f "$TARGET/.claude/settings.json" ]]; then
  echo "  [create] .claude/settings.json (new)"
  cp "$CC/settings.json" "$TARGET/.claude/settings.json"
else
  echo "  [skip]   .claude/settings.json (exists — merge manually if needed)"
fi

# --- Update Cursor rule ---
mkdir -p "$TARGET/.cursor/rules"
echo "  [update] .cursor/rules/forge.mdc"
cp "$CUR/forge.mdc" "$TARGET/.cursor/rules/forge.mdc"

# --- Update Gemini CLI integration ---
echo "  [update] GEMINI.md"
cp "$T/gemini-cli/GEMINI.md" "$TARGET/GEMINI.md"

# --- Update Codex integration (if present in target) ---
if [[ -f "$TARGET/program.md" ]]; then
  echo "  [update] program.md (Codex)"
  cp "$T/codex/program.md" "$TARGET/program.md"
fi

# --- Update Copilot integration (if present in target) ---
if [[ -f "$TARGET/.github/copilot-instructions.md" ]]; then
  echo "  [update] .github/copilot-instructions.md"
  cp "$T/copilot/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
fi

# --- Update loop driver scripts ---
echo "  [update] forge-cycle.sh"
cp "$S_DIR/forge-cycle.sh" "$TARGET/forge-cycle.sh"
chmod +x "$TARGET/forge-cycle.sh"
echo "  [update] forge-obsidian-sync.sh"
cp "$S_DIR/forge-obsidian-sync.sh" "$TARGET/forge-obsidian-sync.sh"
chmod +x "$TARGET/forge-obsidian-sync.sh"
echo "  [update] forge-chart.py"
cp "$S_DIR/forge-chart.py" "$TARGET/forge-chart.py"

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

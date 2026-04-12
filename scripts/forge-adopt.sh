#!/usr/bin/env bash
# Copy THE FORGE Quintet + stack EVAL + agent integration into a target repository.
#
# Copies:
#   templates/universal/  → <target>/ (CLAUDE.md + Quintet templates)
#   templates/stacks/<s>/ → <target>/ (EVAL_SPEC.md + EVAL.sh)
#   templates/cursor/     → <target>/.cursor/rules/
#   templates/claude-code/→ <target>/.claude/
#
# After running:
#   1. Edit FORGE_IDENTITY.md — set ForgeProjectSlug, ObsidianVaultRoot, stack metadata.
#   2. Edit FORGE_SYSTEM.md — fill all six sections (Module map, contracts, scorecard, etc.).
#   3. Fill RESEARCH.md — set the active hypothesis and all 8 required fields.
#   4. Wire PERF_SCORE if needed — see docs/CUSTOMIZING_EVAL.md.
#   5. On Unix/Git Bash: chmod +x EVAL.sh && bash ./EVAL.sh (x3 for baseline).
#   6. Record median SCORE in RESEARCH.md > Baseline Score.
#   7. Create Obsidian folder: Forge/Projects/<ForgeProjectSlug>/ — see docs/OBSIDIAN_SETUP.md.
set -euo pipefail

STACK="minimal"
TARGET=""

usage() {
  cat >&2 <<EOF
Usage: $0 --target /path/to/repo [--stack minimal|python|node|go]

  --target  Absolute path to the destination repository root (required)
  --stack   Stack name for EVAL harness (default: minimal)
EOF
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --stack)  STACK="${2:-}";  shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
done

[[ -n "$TARGET" ]] || { echo "Error: --target is required" >&2; usage; }
[[ -d "$TARGET" ]] || { echo "Error: target not a directory: $TARGET" >&2; exit 2; }

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$KIT_ROOT/templates"
U="$T/universal"
S="$T/stacks/$STACK"
CC="$T/claude-code"
CUR="$T/cursor"

[[ -d "$S" ]] || { echo "Error: stack not found: $S" >&2; exit 2; }

# ── Universal Quintet files ─────────────────────────────────────────────────
cp "$U/CLAUDE.md"                        "$TARGET/CLAUDE.md"
cp "$U/FORGE_IDENTITY.md.template"       "$TARGET/FORGE_IDENTITY.md"
cp "$U/RESEARCH.md.template"             "$TARGET/RESEARCH.md"
cp "$U/FORGE_SYSTEM.md.template"         "$TARGET/FORGE_SYSTEM.md"
cp "$U/PROJECT_LOG.md.template"          "$TARGET/PROJECT_LOG.md"

# ── Stack EVAL harness ──────────────────────────────────────────────────────
cp "$S/EVAL_SPEC.md"                     "$TARGET/EVAL_SPEC.md"
cp "$S/EVAL.sh"                          "$TARGET/EVAL.sh"
chmod +x "$TARGET/EVAL.sh"

# ── Cursor rule ─────────────────────────────────────────────────────────────
mkdir -p "$TARGET/.cursor/rules"
cp "$CUR/forge-v3.mdc"                   "$TARGET/.cursor/rules/forge-v3.mdc"

# ── Claude Code integration ─────────────────────────────────────────────────
mkdir -p "$TARGET/.claude"
cp "$CC/CLAUDE.md"                       "$TARGET/.claude/CLAUDE.md"
# Only copy settings.json if not already present (avoid stomping existing config)
if [[ ! -f "$TARGET/.claude/settings.json" ]]; then
  cp "$CC/settings.json"                 "$TARGET/.claude/settings.json"
else
  echo "  [skip] .claude/settings.json already exists — merge manually if needed"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "Forge templates copied to: $TARGET"
echo "Stack: $STACK"
echo ""
echo "Next steps:"
echo "  1. Edit FORGE_IDENTITY.md  — set ForgeProjectSlug + ObsidianVaultRoot"
echo "  2. Edit FORGE_SYSTEM.md    — fill all six architecture sections"
echo "  3. Fill RESEARCH.md        — set active hypothesis (all 8 fields)"
echo "  4. Wire PERF_SCORE         — see docs/CUSTOMIZING_EVAL.md (optional but recommended)"
echo "  5. Baseline: bash ./EVAL.sh  (run × 3, record median in RESEARCH.md)"
echo "  6. Obsidian: create Forge/Projects/<ForgeProjectSlug>/ in your vault"
echo "     See docs/OBSIDIAN_SETUP.md"
echo ""

#!/usr/bin/env bash
# Copy THE FORGE Quintet + stack EVAL + agent integration into a target repository.
#
# Copies:
#   templates/universal/  → <target>/ (CLAUDE.md + Quintet templates)
#   templates/stacks/<s>/ → <target>/ (EVAL_SPEC.md + EVAL.sh)
#   templates/cursor/     → <target>/.cursor/rules/
#   templates/claude-code/→ <target>/.claude/
#   templates/gemini-cli/ → <target>/
#   templates/codex/      → <target>/          (if codex in platforms)
#   templates/copilot/    → <target>/.github/  (if copilot in platforms)
#   scripts/forge-cycle.sh, forge-obsidian-sync.sh → <target>/
#
# After running (non-interactive):
#   1. Edit FORGE_IDENTITY.md — set ForgeProjectSlug, ObsidianVaultRoot, stack metadata.
#   2. Edit FORGE_SYSTEM.md  — fill all six sections.
#   3. Fill RESEARCH.md       — set the active hypothesis (all 8 required fields).
#   4. Wire PERF_SCORE        — see docs/EVAL_BENCHMARKS.md (optional but recommended).
#   5. Baseline: bash ./forge-cycle.sh --baseline-only
#   6. Obsidian: create Forge/Projects/<ForgeProjectSlug>/ — see docs/OBSIDIAN_SETUP.md.
set -euo pipefail

# ── Defaults ────────────────────────────────────────────────────────────────
STACK=""
TARGET=""
INTERACTIVE=false
PLATFORMS="claude,gemini,cursor,codex,copilot"  # default: all platforms

usage() {
  cat >&2 <<EOF
Usage: $0 --target /path/to/repo [OPTIONS]

Options:
  --target PATH          Absolute path to destination repository root (required)
  --stack STACK          Stack: minimal|python|node|go|rust (auto-detected if omitted)
  --interactive          Interactive setup wizard (fills templates, runs first EVAL)
  --platforms LIST       Comma-separated platform list (default: all)
                         Options: claude,gemini,cursor,codex,copilot

Examples:
  $0 --target ~/my-project
  $0 --target ~/my-project --stack python --interactive
  $0 --target ~/my-project --platforms claude,gemini
EOF
  exit 2
}

# ── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)      TARGET="${2:-}";    shift 2 ;;
    --stack)       STACK="${2:-}";     shift 2 ;;
    --interactive) INTERACTIVE=true;   shift ;;
    --platforms)   PLATFORMS="${2:-}"; shift 2 ;;
    -h|--help)     usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
done

[[ -n "$TARGET" ]] || { echo "Error: --target is required" >&2; usage; }
[[ -d "$TARGET" ]] || { echo "Error: target not a directory: $TARGET" >&2; exit 2; }

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$KIT_ROOT/templates"

# ── Stack auto-detection ─────────────────────────────────────────────────────
if [[ -z "$STACK" ]]; then
  if [[ -f "$TARGET/requirements.txt" || -f "$TARGET/setup.py" || -f "$TARGET/pyproject.toml" ]]; then
    STACK="python"
  elif [[ -f "$TARGET/package.json" ]]; then
    STACK="node"
  elif [[ -f "$TARGET/go.mod" ]]; then
    STACK="go"
  elif [[ -f "$TARGET/Cargo.toml" ]]; then
    STACK="rust"
  else
    STACK="minimal"
  fi
  echo "Auto-detected stack: $STACK"
fi

S="$T/stacks/$STACK"
[[ -d "$S" ]] || { echo "Error: stack not found: $S" >&2; exit 2; }

# ── Interactive wizard ───────────────────────────────────────────────────────
if [[ "$INTERACTIVE" == "true" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  THE FORGE v4 — Interactive Setup"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  read -r -p "  Project name (ForgeProjectSlug, no spaces): " I_SLUG
  read -r -p "  One-line description: " I_DESC
  read -r -p "  Primary thing to improve? (1) speed  (2) correctness  (3) debt [1]: " I_GOAL
  read -r -p "  Obsidian vault path (or Enter to skip): " I_OBS
  read -r -p "  Benchmark command for PERF_SCORE (or Enter to skip): " I_BENCH
  echo ""

  I_SLUG="${I_SLUG:-my-project}"
  I_SLUG="${I_SLUG// /-}"  # replace spaces with dashes
  case "${I_GOAL:-1}" in
    2) I_HYPO_TYPE="Correctness" ;;
    3) I_HYPO_TYPE="Debt" ;;
    *)  I_HYPO_TYPE="Performance" ;;
  esac
fi

# ── Universal Quintet files ──────────────────────────────────────────────────
echo ""
echo "Copying Forge templates to: $TARGET"

cp "$T/universal/FORGE.md"                      "$TARGET/CLAUDE.md"
cp "$T/universal/FORGE_IDENTITY.md.template"    "$TARGET/FORGE_IDENTITY.md"
cp "$T/universal/RESEARCH.md.template"          "$TARGET/RESEARCH.md"
cp "$T/universal/FORGE_SYSTEM.md.template"      "$TARGET/FORGE_SYSTEM.md"
cp "$T/universal/PROJECT_LOG.md.template"       "$TARGET/PROJECT_LOG.md"

# ── Stack EVAL harness ───────────────────────────────────────────────────────
cp "$S/EVAL_SPEC.md"   "$TARGET/EVAL_SPEC.md"
cp "$S/EVAL.sh"        "$TARGET/EVAL.sh"
chmod +x "$TARGET/EVAL.sh"

# Copy benchmark starter if present
[[ -f "$S/benchmark.py" ]] && cp "$S/benchmark.py" "$TARGET/benchmark.py"
[[ -f "$S/benchmark.js" ]] && cp "$S/benchmark.js" "$TARGET/benchmark.js"

# Copy Criterion bench for Rust
if [[ "$STACK" == "rust" && -d "$S/benches" ]]; then
  mkdir -p "$TARGET/benches"
  cp "$S/benches/forge_bench.rs" "$TARGET/benches/forge_bench.rs"
fi

# ── Loop driver scripts ──────────────────────────────────────────────────────
cp "$KIT_ROOT/scripts/forge-cycle.sh"          "$TARGET/forge-cycle.sh"
cp "$KIT_ROOT/scripts/forge-obsidian-sync.sh"  "$TARGET/forge-obsidian-sync.sh"
cp "$KIT_ROOT/scripts/forge-chart.py"          "$TARGET/forge-chart.py"
chmod +x "$TARGET/forge-cycle.sh" "$TARGET/forge-obsidian-sync.sh"

# ── Platform templates (controlled by --platforms) ───────────────────────────
_has_platform() { echo ",$PLATFORMS," | grep -q ",$1,"; }

# Cursor (always included in "cursor" platform)
if _has_platform "cursor"; then
  mkdir -p "$TARGET/.cursor/rules"
  cp "$T/cursor/forge.mdc" "$TARGET/.cursor/rules/forge.mdc"
fi

# Claude Code
if _has_platform "claude"; then
  mkdir -p "$TARGET/.claude"
  cp "$T/claude-code/FORGE_BRIDGE.md" "$TARGET/.claude/CLAUDE.md"
  if [[ ! -f "$TARGET/.claude/settings.json" ]]; then
    cp "$T/claude-code/settings.json" "$TARGET/.claude/settings.json"
  else
    echo "  [skip] .claude/settings.json already exists — merge manually if needed"
  fi
  # Copy forge-cycle skill
  mkdir -p "$TARGET/.claude/skills"
  cp "$T/claude-code/skills/forge-cycle.md" "$TARGET/.claude/skills/forge-cycle.md"
fi

# Gemini CLI
if _has_platform "gemini"; then
  cp "$T/gemini-cli/GEMINI.md" "$TARGET/GEMINI.md"
fi

# Codex
if _has_platform "codex"; then
  cp "$T/codex/program.md" "$TARGET/program.md"
fi

# GitHub Copilot
if _has_platform "copilot"; then
  mkdir -p "$TARGET/.github"
  cp "$T/copilot/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"
fi

# ── Interactive auto-fill ─────────────────────────────────────────────────────
if [[ "$INTERACTIVE" == "true" ]]; then
  # Fill FORGE_IDENTITY.md
  sed -i "s/ForgeProjectSlug:.*/ForgeProjectSlug: ${I_SLUG}/" "$TARGET/FORGE_IDENTITY.md" 2>/dev/null || true
  [[ -n "${I_OBS:-}" ]] && sed -i "s|ObsidianVaultRoot:.*|ObsidianVaultRoot: ${I_OBS}|" "$TARGET/FORGE_IDENTITY.md" 2>/dev/null || true
  [[ -n "${I_BENCH:-}" ]] && echo "FORGE_BENCH_CMD: ${I_BENCH}" >> "$TARGET/FORGE_IDENTITY.md"

  # Fill RESEARCH.md hypothesis type placeholder comment
  sed -i "s/Exactly one of: \*\*Performance\*\* | \*\*Correctness\*\* | \*\*Debt\*\* | \*\*Architecture\*\*/${I_HYPO_TYPE}/" \
    "$TARGET/RESEARCH.md" 2>/dev/null || true

  echo ""
  echo "Auto-filled FORGE_IDENTITY.md with:"
  echo "  ForgeProjectSlug: ${I_SLUG}"
  [[ -n "${I_OBS:-}" ]] && echo "  ObsidianVaultRoot: ${I_OBS}"
  [[ -n "${I_BENCH:-}" ]] && echo "  FORGE_BENCH_CMD: ${I_BENCH}"

  # Run first EVAL
  echo ""
  echo "Running initial EVAL.sh × 1 to verify setup..."
  cd "$TARGET"
  set +e
  bash ./EVAL.sh
  EVAL_EXIT=$?
  set -e
  cd - >/dev/null

  if [[ $EVAL_EXIT -eq 2 ]]; then
    echo ""
    echo "  WARN: EVAL.sh exited with code 2 (environment error). Fix env before running forge-cycle.sh."
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Forge templates copied to: $TARGET"
echo "  Stack: $STACK | Platforms: $PLATFORMS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [[ "$INTERACTIVE" == "true" ]]; then
  echo "Next steps:"
  echo "  1. Fill remaining sections in RESEARCH.md (hypothesis, target, etc.)"
  echo "  2. Fill FORGE_SYSTEM.md (6 architecture sections)"
  echo "  3. Run the loop: bash ./forge-cycle.sh --baseline-only"
  echo "  4. Obsidian: create Forge/Projects/${I_SLUG:-<slug>}/ in your vault"
  echo "     See docs/OBSIDIAN_SETUP.md"
else
  echo "Next steps:"
  echo "  1. Edit FORGE_IDENTITY.md  — set ForgeProjectSlug + ObsidianVaultRoot"
  echo "  2. Edit FORGE_SYSTEM.md    — fill all six architecture sections"
  echo "  3. Fill RESEARCH.md        — set active hypothesis (all 8 fields)"
  echo "  4. Wire PERF_SCORE         — see docs/EVAL_BENCHMARKS.md (optional)"
  echo "  5. Baseline: bash ./forge-cycle.sh --baseline-only"
  echo "  6. Obsidian: create Forge/Projects/<ForgeProjectSlug>/ in your vault"
  echo "     See docs/OBSIDIAN_SETUP.md"
fi
echo ""

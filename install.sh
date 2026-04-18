#!/usr/bin/env bash
# THE FORGE — one-line installer
#
# Usage (from your project directory):
#   bash <(curl -fsSL https://raw.githubusercontent.com/yash-dev007/THE-FORGE/main/install.sh)
#
# With options:
#   bash <(curl -fsSL .../install.sh) -- --stack python --platforms claude,gemini
#   bash <(curl -fsSL .../install.sh) -- --no-interactive
#
# What this does:
#   1. Clones THE FORGE to ~/.forge (or updates it if already there)
#   2. Runs forge-adopt.sh --target <CWD> --interactive (plus any extra args)
#
set -euo pipefail

FORGE_HOME="${FORGE_HOME:-$HOME/.forge}"
REPO="https://github.com/yash-dev007/THE-FORGE.git"
TARGET="$(pwd)"
INTERACTIVE=true
EXTRA_ARGS=()

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-interactive) INTERACTIVE=false; shift ;;
    --forge-home)     FORGE_HOME="$2"; shift 2 ;;
    *)                EXTRA_ARGS+=("$1"); shift ;;
  esac
done

# ── Colors ────────────────────────────────────────────────────────────────────
BLU='\033[0;34m'; GRN='\033[0;32m'; YEL='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${BLU}[FORGE]${NC} $*"; }
ok()    { echo -e "${GRN}[FORGE]${NC} $*"; }
warn()  { echo -e "${YEL}[FORGE]${NC} $*"; }
err()   { echo -e "${RED}[FORGE]${NC} $*" >&2; exit 1; }

# ── Dependency check ──────────────────────────────────────────────────────────
command -v git >/dev/null 2>&1 || err "git is required but not found. Install git and retry."
command -v bash >/dev/null 2>&1 || err "bash is required."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  THE FORGE v4 — Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Clone or update ~/.forge ──────────────────────────────────────────────────
if [[ -d "$FORGE_HOME/.git" ]]; then
  info "Updating existing Forge kit at $FORGE_HOME ..."
  git -C "$FORGE_HOME" pull --ff-only --quiet
  ok "Kit updated."
else
  info "Cloning THE FORGE to $FORGE_HOME ..."
  git clone --depth 1 --quiet "$REPO" "$FORGE_HOME"
  ok "Kit cloned."
fi

# ── Run adopt ────────────────────────────────────────────────────────────────
ADOPT="$FORGE_HOME/scripts/forge-adopt.sh"
[[ -f "$ADOPT" ]] || err "forge-adopt.sh not found in kit. Try deleting $FORGE_HOME and re-running."
chmod +x "$ADOPT"

info "Adopting Forge into: $TARGET"
echo ""

ADOPT_ARGS=(--target "$TARGET")
[[ "$INTERACTIVE" == "true" ]] && ADOPT_ARGS+=(--interactive)
ADOPT_ARGS+=("${EXTRA_ARGS[@]}")

bash "$ADOPT" "${ADOPT_ARGS[@]}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Done. Forge kit lives at: $FORGE_HOME"
echo ""
echo "  To update the kit later:"
echo "    bash \$HOME/.forge/scripts/forge-update.sh"
echo ""
echo "  To run a cycle:"
echo "    bash ./forge-cycle.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

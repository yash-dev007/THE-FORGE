<#
.SYNOPSIS
  Copy THE FORGE Quintet + stack EVAL + agent integration into a target repository.

.DESCRIPTION
  Copies all Forge templates into the target repo:
    - Quintet files (CLAUDE.md, FORGE_IDENTITY.md, RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md)
    - Stack EVAL harness (EVAL_SPEC.md + EVAL.sh)
    - Cursor rule (.cursor/rules/forge-v3.mdc)
    - Claude Code integration (.claude/CLAUDE.md + .claude/settings.json)

  After running:
    1. Edit FORGE_IDENTITY.md — set ForgeProjectSlug, ObsidianVaultRoot, stack metadata.
    2. Edit FORGE_SYSTEM.md — fill all six sections (Module map, contracts, scorecard, etc.).
    3. Fill RESEARCH.md — set the active hypothesis and all 8 required fields.
    4. Wire PERF_SCORE if needed — see docs/CUSTOMIZING_EVAL.md.
    5. On Git Bash: chmod +x EVAL.sh && bash ./EVAL.sh (x3 for baseline).
    6. Record median SCORE in RESEARCH.md > Baseline Score.
    7. Create Obsidian folder: Forge/Projects/<ForgeProjectSlug>/ — see docs/OBSIDIAN_SETUP.md.

.PARAMETER TargetRepo
  Absolute path to the destination repository root.

.PARAMETER Stack
  Stack name for the EVAL harness: minimal | python | node | go (default: minimal).

.EXAMPLE
  .\forge-adopt.ps1 -TargetRepo 'D:\projects\my-app' -Stack python
#>
param(
  [Parameter(Mandatory = $true)]
  [string] $TargetRepo,

  [Parameter(Mandatory = $false)]
  [ValidateSet("minimal", "python", "node", "go")]
  [string] $Stack = "minimal"
)

$ErrorActionPreference = "Stop"
$KitRoot   = Split-Path -Parent $PSScriptRoot
$Templates = Join-Path $KitRoot "templates"

function Copy-FileSafe($src, $dst) {
  $dir = Split-Path -Parent $dst
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  Copy-Item -LiteralPath $src -Destination $dst -Force
}

$Universal  = Join-Path $Templates "universal"
$StackDir   = Join-Path (Join-Path $Templates "stacks") $Stack
$ClaudeCode = Join-Path $Templates "claude-code"
$CursorDir  = Join-Path $Templates "cursor"

# ── Universal Quintet files ─────────────────────────────────────────────────
Copy-FileSafe (Join-Path $Universal "CLAUDE.md")                  (Join-Path $TargetRepo "CLAUDE.md")
Copy-FileSafe (Join-Path $Universal "FORGE_IDENTITY.md.template") (Join-Path $TargetRepo "FORGE_IDENTITY.md")
Copy-FileSafe (Join-Path $Universal "RESEARCH.md.template")       (Join-Path $TargetRepo "RESEARCH.md")
Copy-FileSafe (Join-Path $Universal "FORGE_SYSTEM.md.template")   (Join-Path $TargetRepo "FORGE_SYSTEM.md")
Copy-FileSafe (Join-Path $Universal "PROJECT_LOG.md.template")    (Join-Path $TargetRepo "PROJECT_LOG.md")

# ── Stack EVAL harness ──────────────────────────────────────────────────────
Copy-FileSafe (Join-Path $StackDir "EVAL_SPEC.md") (Join-Path $TargetRepo "EVAL_SPEC.md")
Copy-FileSafe (Join-Path $StackDir "EVAL.sh")      (Join-Path $TargetRepo "EVAL.sh")

# ── Cursor rule ─────────────────────────────────────────────────────────────
$CursorRulesDst = Join-Path $TargetRepo ".cursor\rules"
if (-not (Test-Path $CursorRulesDst)) { New-Item -ItemType Directory -Force -Path $CursorRulesDst | Out-Null }
Copy-FileSafe (Join-Path $CursorDir "forge-v3.mdc") (Join-Path $CursorRulesDst "forge-v3.mdc")

# ── Claude Code integration ─────────────────────────────────────────────────
$ClaudeDst = Join-Path $TargetRepo ".claude"
if (-not (Test-Path $ClaudeDst)) { New-Item -ItemType Directory -Force -Path $ClaudeDst | Out-Null }
Copy-FileSafe (Join-Path $ClaudeCode "CLAUDE.md") (Join-Path $ClaudeDst "CLAUDE.md")

$SettingsDst = Join-Path $ClaudeDst "settings.json"
if (-not (Test-Path $SettingsDst)) {
  Copy-FileSafe (Join-Path $ClaudeCode "settings.json") $SettingsDst
} else {
  Write-Host "  [skip] .claude\settings.json already exists — merge manually if needed"
}

# ── Summary ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Forge templates copied to: $TargetRepo"
Write-Host "Stack: $Stack"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit FORGE_IDENTITY.md  — set ForgeProjectSlug + ObsidianVaultRoot"
Write-Host "  2. Edit FORGE_SYSTEM.md    — fill all six architecture sections"
Write-Host "  3. Fill RESEARCH.md        — set active hypothesis (all 8 fields)"
Write-Host "  4. Wire PERF_SCORE         — see docs/CUSTOMIZING_EVAL.md (optional but recommended)"
Write-Host "  5. Baseline: bash ./EVAL.sh  (run x3, record median in RESEARCH.md)"
Write-Host "  6. Obsidian: create Forge/Projects/<ForgeProjectSlug>/ in your vault"
Write-Host "     See docs/OBSIDIAN_SETUP.md"
Write-Host ""

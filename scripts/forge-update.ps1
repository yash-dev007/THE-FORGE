<#
.SYNOPSIS
  Refresh THE FORGE methodology templates in an already-adopted repository.

.DESCRIPTION
  Copies CLAUDE.md, Claude Code integration files (.claude/), and the Cursor rule
  into the target repo. Does NOT overwrite project state files (FORGE_IDENTITY.md,
  RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md).

  Use -UpdateEval to also refresh EVAL.sh + EVAL_SPEC.md from the chosen stack
  template. WARNING: this resets the scoring baseline — re-run EVAL.sh three times
  and record a new median in RESEARCH.md before resuming hypothesis cycles.

.PARAMETER TargetRepo
  Absolute path to the already-adopted repository root.

.PARAMETER Stack
  Stack name: minimal | python | node | go (required when -UpdateEval is set).

.PARAMETER UpdateEval
  Switch. Also refreshes EVAL.sh and EVAL_SPEC.md. Use carefully — resets baseline.

.EXAMPLE
  .\forge-update.ps1 -TargetRepo 'D:\projects\my-app'
  .\forge-update.ps1 -TargetRepo 'D:\projects\my-app' -Stack python -UpdateEval
#>
param(
  [Parameter(Mandatory = $true)]
  [string] $TargetRepo,

  [Parameter(Mandatory = $false)]
  [ValidateSet("minimal", "python", "node", "go")]
  [string] $Stack = "",

  [switch] $UpdateEval
)

$ErrorActionPreference = "Stop"

if ($UpdateEval -and [string]::IsNullOrEmpty($Stack)) {
  Write-Error "-Stack is required when -UpdateEval is set."
  exit 2
}

if (-not (Test-Path $TargetRepo -PathType Container)) {
  Write-Error "Target not a directory: $TargetRepo"
  exit 2
}

$KitRoot   = Split-Path -Parent $PSScriptRoot
$Templates = Join-Path $KitRoot "templates"
$Universal = Join-Path $Templates "universal"
$ClaudeCC  = Join-Path $Templates "claude-code"
$CursorDir = Join-Path $Templates "cursor"

function Copy-FileSafe($src, $dst) {
  $dir = Split-Path -Parent $dst
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  Copy-Item -LiteralPath $src -Destination $dst -Force
}

# --- Update CLAUDE.md ---
Write-Host "  [update] CLAUDE.md"
Copy-FileSafe (Join-Path $Universal "CLAUDE.md") (Join-Path $TargetRepo "CLAUDE.md")

# --- Update Claude Code integration ---
$claudeDir = Join-Path $TargetRepo ".claude"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null }

Write-Host "  [update] .claude\CLAUDE.md"
Copy-FileSafe (Join-Path $ClaudeCC "CLAUDE.md") (Join-Path $claudeDir "CLAUDE.md")

$settingsDst = Join-Path $claudeDir "settings.json"
if (-not (Test-Path $settingsDst)) {
  Write-Host "  [create] .claude\settings.json (new)"
  Copy-FileSafe (Join-Path $ClaudeCC "settings.json") $settingsDst
} else {
  Write-Host "  [skip]   .claude\settings.json (exists — merge manually if needed)"
}

# --- Update Cursor rule ---
$cursorRulesDst = Join-Path $TargetRepo ".cursor\rules"
if (-not (Test-Path $cursorRulesDst)) { New-Item -ItemType Directory -Force -Path $cursorRulesDst | Out-Null }
Write-Host "  [update] .cursor\rules\forge-v3.mdc"
Copy-FileSafe (Join-Path $CursorDir "forge-v3.mdc") (Join-Path $cursorRulesDst "forge-v3.mdc")

# --- Optionally update EVAL harness ---
if ($UpdateEval) {
  $StackDir = Join-Path (Join-Path $Templates "stacks") $Stack
  if (-not (Test-Path $StackDir -PathType Container)) {
    Write-Error "Stack directory not found: $StackDir"
    exit 2
  }
  Write-Host ""
  Write-Host "  [update] EVAL_SPEC.md + EVAL.sh  *** BASELINE RESET — see warning below ***"
  Copy-FileSafe (Join-Path $StackDir "EVAL_SPEC.md") (Join-Path $TargetRepo "EVAL_SPEC.md")
  Copy-FileSafe (Join-Path $StackDir "EVAL.sh")      (Join-Path $TargetRepo "EVAL.sh")
}

Write-Host ""
Write-Host "Update complete: $TargetRepo"
Write-Host ""

if ($UpdateEval) {
  Write-Host "  *** EVAL.sh was refreshed. You MUST:"
  Write-Host "      1. Run ./EVAL.sh three times on unchanged code (Git Bash)."
  Write-Host "      2. Record the new median in RESEARCH.md > Baseline Score."
  Write-Host "      3. Note the harness change in PROJECT_LOG.md."
  Write-Host "      Hypothesis cycles must not resume until baseline is re-established. ***"
  Write-Host ""
}

Write-Host "  Files NOT updated (project state — update manually if needed):"
Write-Host "    FORGE_IDENTITY.md, RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md"

<#
.SYNOPSIS
  Refresh THE FORGE methodology templates in an already-adopted repository.

.DESCRIPTION
  Refreshes CLAUDE.md, all platform bridge files (.claude/, GEMINI.md, forge.mdc,
  program.md, copilot-instructions.md), and loop driver scripts (forge-cycle.sh,
  forge-obsidian-sync.sh, forge-chart.py). Does NOT overwrite project state files
  (FORGE_IDENTITY.md, RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md).

  Use -UpdateEval to also refresh EVAL.sh + EVAL_SPEC.md from the chosen stack
  template. WARNING: this resets the scoring baseline — re-run EVAL.sh three times
  and record a new median in RESEARCH.md before resuming hypothesis cycles.

.PARAMETER TargetRepo
  Absolute path to the already-adopted repository root.

.PARAMETER Stack
  Stack name: minimal | python | node | go | rust (required when -UpdateEval is set).

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
  [ValidateSet("minimal", "python", "node", "go", "rust")]
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
$Scripts   = Join-Path $KitRoot "scripts"
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
Copy-FileSafe (Join-Path $Universal "FORGE.md") (Join-Path $TargetRepo "CLAUDE.md")

# --- Update Claude Code integration ---
$claudeDir = Join-Path $TargetRepo ".claude"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null }

Write-Host "  [update] .claude\CLAUDE.md"
Copy-FileSafe (Join-Path $ClaudeCC "FORGE_BRIDGE.md") (Join-Path $claudeDir "CLAUDE.md")

$skillsDst = Join-Path $claudeDir "skills"
if (-not (Test-Path $skillsDst)) { New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null }
Write-Host "  [update] .claude\skills\forge-cycle.md"
Copy-FileSafe (Join-Path $ClaudeCC "skills\forge-cycle.md") (Join-Path $skillsDst "forge-cycle.md")

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
Write-Host "  [update] .cursor\rules\forge.mdc"
Copy-FileSafe (Join-Path $CursorDir "forge.mdc") (Join-Path $cursorRulesDst "forge.mdc")

# --- Update Gemini CLI integration ---
Write-Host "  [update] GEMINI.md"
Copy-FileSafe (Join-Path $Templates "gemini-cli\GEMINI.md") (Join-Path $TargetRepo "GEMINI.md")

# --- Update Codex integration (if present in target) ---
$CodexDst = Join-Path $TargetRepo "program.md"
if (Test-Path $CodexDst) {
  Write-Host "  [update] program.md (Codex)"
  Copy-FileSafe (Join-Path $Templates "codex\program.md") $CodexDst
}

# --- Update Copilot integration (if present in target) ---
$CopilotDst = Join-Path $TargetRepo ".github\copilot-instructions.md"
if (Test-Path $CopilotDst) {
  Write-Host "  [update] .github\copilot-instructions.md"
  Copy-FileSafe (Join-Path $Templates "copilot\copilot-instructions.md") $CopilotDst
}

# --- Update loop driver scripts ---
Write-Host "  [update] forge-cycle.sh"
Copy-FileSafe (Join-Path $Scripts "forge-cycle.sh") (Join-Path $TargetRepo "forge-cycle.sh")
Write-Host "  [update] forge-obsidian-sync.sh"
Copy-FileSafe (Join-Path $Scripts "forge-obsidian-sync.sh") (Join-Path $TargetRepo "forge-obsidian-sync.sh")
Write-Host "  [update] forge-chart.py"
Copy-FileSafe (Join-Path $Scripts "forge-chart.py") (Join-Path $TargetRepo "forge-chart.py")

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
  Write-Host "      1. On Git Bash/WSL: chmod +x EVAL.sh  (Copy-Item does not set the execute bit)."
  Write-Host "      2. Run ./EVAL.sh three times on unchanged code (Git Bash)."
  Write-Host "      3. Record the new median in RESEARCH.md > Baseline Score."
  Write-Host "      4. Note the harness change in PROJECT_LOG.md."
  Write-Host "      Hypothesis cycles must not resume until baseline is re-established. ***"
  Write-Host ""
}

Write-Host "  Files NOT updated (project state — update manually if needed):"
Write-Host "    FORGE_IDENTITY.md, RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md"

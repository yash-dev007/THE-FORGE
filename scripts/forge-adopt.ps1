<#
.SYNOPSIS
  Copy THE FORGE Quintet + stack EVAL + agent integration into a target repository.

.DESCRIPTION
  Copies all Forge v4 templates into the target repo:
    - Quintet files (CLAUDE.md, FORGE_IDENTITY.md, RESEARCH.md, FORGE_SYSTEM.md, PROJECT_LOG.md)
    - Stack EVAL harness (EVAL_SPEC.md + EVAL.sh + benchmark starters)
    - Loop driver scripts (forge-cycle.sh, forge-obsidian-sync.sh, forge-chart.py)
    - Platform templates (controlled by -Platforms)

  After running (non-interactive):
    1. Edit FORGE_IDENTITY.md — set ForgeProjectSlug, ObsidianVaultRoot, stack metadata.
    2. Edit FORGE_SYSTEM.md — fill all six sections (Module map, contracts, scorecard, etc.).
    3. Fill RESEARCH.md — set the active hypothesis and all 8 required fields.
    4. Wire PERF_SCORE if needed — see docs/EVAL_BENCHMARKS.md.
    5. Baseline: bash ./forge-cycle.sh --baseline-only
    6. Create Obsidian folder: Forge/Projects/<ForgeProjectSlug>/ — see docs/OBSIDIAN_SETUP.md.

.PARAMETER TargetRepo
  Absolute path to the destination repository root.

.PARAMETER Stack
  Stack name for the EVAL harness: minimal | python | node | go | rust (auto-detected if omitted).

.PARAMETER Interactive
  Run interactive setup wizard (fills templates, runs first EVAL).

.PARAMETER Platforms
  Comma-separated platform list. Default: "claude,gemini,cursor,codex,copilot" (all).
  Options: claude, gemini, cursor, codex, copilot

.EXAMPLE
  .\forge-adopt.ps1 -TargetRepo 'D:\projects\my-app'
  .\forge-adopt.ps1 -TargetRepo 'D:\projects\my-app' -Stack python -Interactive
  .\forge-adopt.ps1 -TargetRepo 'D:\projects\my-app' -Platforms "claude,gemini"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepo,

    [Parameter(Mandatory = $false)]
    [ValidateSet("minimal", "python", "node", "go", "rust", "")]
    [string]$Stack = "",

    [switch]$Interactive,

    [string]$Platforms = "claude,gemini,cursor,codex,copilot"
)

$ErrorActionPreference = "Stop"
$KitRoot   = Split-Path -Parent $PSScriptRoot
$Templates = Join-Path $KitRoot "templates"
$Scripts   = Join-Path $KitRoot "scripts"

function Copy-FileSafe([string]$src, [string]$dst) {
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Copy-Item -LiteralPath $src -Destination $dst -Force
}

function Has-Platform([string]$name) {
    return ",$Platforms," -like "*,$name,*"
}

# ── Stack auto-detection ──────────────────────────────────────────────────────
if ([string]::IsNullOrEmpty($Stack)) {
    if (Test-Path (Join-Path $TargetRepo "requirements.txt")) { $Stack = "python" }
    elseif (Test-Path (Join-Path $TargetRepo "pyproject.toml")) { $Stack = "python" }
    elseif (Test-Path (Join-Path $TargetRepo "setup.py"))       { $Stack = "python" }
    elseif (Test-Path (Join-Path $TargetRepo "package.json"))   { $Stack = "node" }
    elseif (Test-Path (Join-Path $TargetRepo "go.mod"))         { $Stack = "go" }
    elseif (Test-Path (Join-Path $TargetRepo "Cargo.toml"))     { $Stack = "rust" }
    else { $Stack = "minimal" }
    Write-Host "Auto-detected stack: $Stack"
}

$StackDir = Join-Path $Templates "stacks\$Stack"
if (-not (Test-Path $StackDir)) {
    Write-Error "Stack not found: $StackDir"
    exit 2
}

# ── Interactive wizard ────────────────────────────────────────────────────────
$ISlug = ""; $IObs = ""; $IBench = ""; $IHypoType = "Performance"
if ($Interactive) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "  THE FORGE v4 — Interactive Setup"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    $ISlug     = (Read-Host "  Project name (ForgeProjectSlug, no spaces)").Replace(" ", "-")
    $IDesc     = Read-Host "  One-line description"
    $IGoal     = Read-Host "  Primary thing to improve? (1) speed  (2) correctness  (3) debt [1]"
    $IObs      = Read-Host "  Obsidian vault path (or Enter to skip)"
    $IBench    = Read-Host "  Benchmark command for PERF_SCORE (or Enter to skip)"
    switch ($IGoal) {
        "2" { $IHypoType = "Correctness" }
        "3" { $IHypoType = "Debt" }
        default { $IHypoType = "Performance" }
    }
    if ([string]::IsNullOrEmpty($ISlug)) { $ISlug = "my-project" }
}

# ── Universal Quintet files ───────────────────────────────────────────────────
$Universal = Join-Path $Templates "universal"
Write-Host ""
Write-Host "Copying Forge templates to: $TargetRepo"

Copy-FileSafe (Join-Path $Universal "FORGE.md")                   (Join-Path $TargetRepo "CLAUDE.md")
Copy-FileSafe (Join-Path $Universal "FORGE_IDENTITY.md.template") (Join-Path $TargetRepo "FORGE_IDENTITY.md")
Copy-FileSafe (Join-Path $Universal "RESEARCH.md.template")       (Join-Path $TargetRepo "RESEARCH.md")
Copy-FileSafe (Join-Path $Universal "FORGE_SYSTEM.md.template")   (Join-Path $TargetRepo "FORGE_SYSTEM.md")
Copy-FileSafe (Join-Path $Universal "PROJECT_LOG.md.template")    (Join-Path $TargetRepo "PROJECT_LOG.md")

# ── Stack EVAL harness ────────────────────────────────────────────────────────
Copy-FileSafe (Join-Path $StackDir "EVAL_SPEC.md") (Join-Path $TargetRepo "EVAL_SPEC.md")
Copy-FileSafe (Join-Path $StackDir "EVAL.sh")      (Join-Path $TargetRepo "EVAL.sh")

$BenchPy = Join-Path $StackDir "benchmark.py"
if (Test-Path $BenchPy) { Copy-FileSafe $BenchPy (Join-Path $TargetRepo "benchmark.py") }
$BenchJs = Join-Path $StackDir "benchmark.js"
if (Test-Path $BenchJs) { Copy-FileSafe $BenchJs (Join-Path $TargetRepo "benchmark.js") }
if ($Stack -eq "rust") {
    $BenchesDir = Join-Path $StackDir "benches"
    if (Test-Path $BenchesDir) {
        $DstBenches = Join-Path $TargetRepo "benches"
        if (-not (Test-Path $DstBenches)) { New-Item -ItemType Directory -Force -Path $DstBenches | Out-Null }
        Copy-Item (Join-Path $BenchesDir "forge_bench.rs") (Join-Path $DstBenches "forge_bench.rs") -Force
    }
}

# ── Loop driver scripts ───────────────────────────────────────────────────────
Copy-FileSafe (Join-Path $Scripts "forge-cycle.sh")         (Join-Path $TargetRepo "forge-cycle.sh")
Copy-FileSafe (Join-Path $Scripts "forge-obsidian-sync.sh") (Join-Path $TargetRepo "forge-obsidian-sync.sh")
Copy-FileSafe (Join-Path $Scripts "forge-chart.py")         (Join-Path $TargetRepo "forge-chart.py")

# ── Platform templates ────────────────────────────────────────────────────────
if (Has-Platform "cursor") {
    $CursorDst = Join-Path $TargetRepo ".cursor\rules"
    if (-not (Test-Path $CursorDst)) { New-Item -ItemType Directory -Force -Path $CursorDst | Out-Null }
    Copy-FileSafe (Join-Path $Templates "cursor\forge.mdc") (Join-Path $CursorDst "forge.mdc")
}

if (Has-Platform "claude") {
    $ClaudeDst = Join-Path $TargetRepo ".claude"
    if (-not (Test-Path $ClaudeDst)) { New-Item -ItemType Directory -Force -Path $ClaudeDst | Out-Null }
    Copy-FileSafe (Join-Path $Templates "claude-code\FORGE_BRIDGE.md") (Join-Path $ClaudeDst "CLAUDE.md")
    $SettingsDst = Join-Path $ClaudeDst "settings.json"
    if (-not (Test-Path $SettingsDst)) {
        Copy-FileSafe (Join-Path $Templates "claude-code\settings.json") $SettingsDst
    } else {
        Write-Host "  [skip] .claude\settings.json already exists — merge manually if needed"
    }
    $SkillsDst = Join-Path $ClaudeDst "skills"
    if (-not (Test-Path $SkillsDst)) { New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null }
    Copy-FileSafe (Join-Path $Templates "claude-code\skills\forge-cycle.md") (Join-Path $SkillsDst "forge-cycle.md")
}

if (Has-Platform "gemini") {
    Copy-FileSafe (Join-Path $Templates "gemini-cli\GEMINI.md") (Join-Path $TargetRepo "GEMINI.md")
}

if (Has-Platform "codex") {
    Copy-FileSafe (Join-Path $Templates "codex\program.md") (Join-Path $TargetRepo "program.md")
}

if (Has-Platform "copilot") {
    $GhDst = Join-Path $TargetRepo ".github"
    if (-not (Test-Path $GhDst)) { New-Item -ItemType Directory -Force -Path $GhDst | Out-Null }
    Copy-FileSafe (Join-Path $Templates "copilot\copilot-instructions.md") (Join-Path $GhDst "copilot-instructions.md")
}

# ── Interactive auto-fill ─────────────────────────────────────────────────────
if ($Interactive -and -not [string]::IsNullOrEmpty($ISlug)) {
    $IdentityFile = Join-Path $TargetRepo "FORGE_IDENTITY.md"
    $content = Get-Content $IdentityFile -Raw
    $content = $content -replace "ForgeProjectSlug:.*", "ForgeProjectSlug: $ISlug"
    if (-not [string]::IsNullOrEmpty($IObs)) {
        $content = $content -replace "ObsidianVaultRoot:.*", "ObsidianVaultRoot: $IObs"
    }
    Set-Content $IdentityFile $content
    if (-not [string]::IsNullOrEmpty($IBench)) {
        Add-Content $IdentityFile "`nFORGE_BENCH_CMD: $IBench"
    }
    Write-Host ""
    Write-Host "Auto-filled FORGE_IDENTITY.md:"
    Write-Host "  ForgeProjectSlug: $ISlug"
    if (-not [string]::IsNullOrEmpty($IObs))   { Write-Host "  ObsidianVaultRoot: $IObs" }
    if (-not [string]::IsNullOrEmpty($IBench)) { Write-Host "  FORGE_BENCH_CMD: $IBench" }
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "  Forge templates copied to: $TargetRepo"
Write-Host "  Stack: $Stack | Platforms: $Platforms"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""
if ($Interactive) {
    Write-Host "Next steps:"
    Write-Host "  1. Fill remaining RESEARCH.md fields (hypothesis, target, etc.)"
    Write-Host "  2. Fill FORGE_SYSTEM.md (6 architecture sections)"
    Write-Host "  3. Run the loop: bash ./forge-cycle.sh --baseline-only"
    Write-Host "  4. Obsidian: create Forge/Projects/$ISlug/ in your vault"
    Write-Host "     See docs/OBSIDIAN_SETUP.md"
} else {
    Write-Host "Next steps:"
    Write-Host "  1. Edit FORGE_IDENTITY.md  — set ForgeProjectSlug + ObsidianVaultRoot"
    Write-Host "  2. Edit FORGE_SYSTEM.md    — fill all six architecture sections"
    Write-Host "  3. Fill RESEARCH.md        — set active hypothesis (all 8 fields)"
    Write-Host "  4. Wire PERF_SCORE         — see docs/EVAL_BENCHMARKS.md (optional)"
    Write-Host "  5. Baseline: bash ./forge-cycle.sh --baseline-only"
    Write-Host "  6. Obsidian: create Forge/Projects/<ForgeProjectSlug>/ in your vault"
    Write-Host "     See docs/OBSIDIAN_SETUP.md"
}
Write-Host ""

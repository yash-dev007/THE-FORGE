# forge-obsidian-sync.ps1 — THE FORGE v4 Obsidian sync (PowerShell wrapper)
# Delegates to forge-obsidian-sync.sh via Git Bash.
# Called by forge-cycle.ps1 or directly after a cycle.
[CmdletBinding()]
param(
    [string]$Slug       = "",
    [string]$ObsRoot    = "",
    [string]$Cycle      = "",
    [string]$Baseline   = "",
    [string]$NewScore   = "",
    [string]$Delta      = "",
    [string]$Decision   = "",
    [string]$Hypothesis = "",
    [string]$Date       = (Get-Date -Format "yyyy-MM-dd")
)

$ErrorActionPreference = "Stop"

$BashCandidates = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files\Git\usr\bin\bash.exe",
    "bash"
)

$Bash = $null
foreach ($candidate in $BashCandidates) {
    if (Get-Command $candidate -ErrorAction SilentlyContinue) {
        $Bash = $candidate
        break
    }
}

if (-not $Bash) {
    Write-Warning "[FORGE] bash not found — Obsidian sync skipped."
    exit 0
}

if (-not (Test-Path "forge-obsidian-sync.sh")) {
    Write-Warning "[FORGE] forge-obsidian-sync.sh not found — sync skipped."
    exit 0
}

& $Bash "./forge-obsidian-sync.sh" `
    --slug       $Slug `
    --obs-root   $ObsRoot `
    --cycle      $Cycle `
    --baseline   $Baseline `
    --new-score  $NewScore `
    --delta      $Delta `
    --decision   $Decision `
    --hypothesis $Hypothesis `
    --date       $Date

exit $LASTEXITCODE

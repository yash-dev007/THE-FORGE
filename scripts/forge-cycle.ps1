# forge-cycle.ps1 — THE FORGE v4 loop driver (PowerShell wrapper for Windows)
# Copied to adopted repos by forge-adopt.ps1. Run from repo root.
#
# Usage:
#   .\forge-cycle.ps1                        # Full interactive cycle
#   .\forge-cycle.ps1 -BaselineOnly          # Run baseline only
#   .\forge-cycle.ps1 -SkipBaseline 6.50     # Evaluate against existing score
#
# Requires Git Bash or WSL installed. Delegates all logic to forge-cycle.sh.
[CmdletBinding()]
param(
    [switch]$BaselineOnly,
    [string]$SkipBaseline = ""
)

$ErrorActionPreference = "Stop"

# ── Locate bash ──────────────────────────────────────────────────────────────
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
    Write-Error "[FORGE] BLOCKED — bash not found. Install Git for Windows (https://git-scm.com) or WSL."
    exit 1
}

# ── Check forge-cycle.sh exists ──────────────────────────────────────────────
if (-not (Test-Path "forge-cycle.sh")) {
    Write-Error "[FORGE] BLOCKED — forge-cycle.sh not found in current directory. Run from repo root."
    exit 1
}

# ── Build args and delegate ───────────────────────────────────────────────────
$ShArgs = @("./forge-cycle.sh")

if ($BaselineOnly) {
    $ShArgs += "--baseline-only"
}
elseif ($SkipBaseline -ne "") {
    $ShArgs += "--skip-baseline"
    $ShArgs += $SkipBaseline
}

Write-Host "[FORGE] Delegating to forge-cycle.sh via bash..." -ForegroundColor Cyan
& $Bash @ShArgs
exit $LASTEXITCODE

param(
    [switch]$SkipBackendTests,
    [switch]$SkipFrontendLint,
    [switch]$SkipFrontendTests
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
    param(
        [string]$Message,
        [ScriptBlock]$Action
    )

    Write-Host "[verify] $Message" -ForegroundColor Cyan
    & $Action
    Write-Host "[verify] Completed: $Message" -ForegroundColor Green
}

$scriptPath = Split-Path -Parent $PSCommandPath
$repoRoot = Split-Path -Parent $scriptPath

if (-not $SkipBackendTests) {
    Invoke-Step -Message "dotnet test (Backend)" -Action {
        dotnet test "$repoRoot\Backend\exemploAPIVendas.slnx" --nologo
    }
}

Push-Location "$repoRoot\Frontend"
try {
    if (-not $SkipFrontendLint) {
        Invoke-Step -Message "npm run lint (Frontend)" -Action {
            npm run lint -- --no-progress
        }
    }

    if (-not $SkipFrontendTests) {
        Invoke-Step -Message "npm run test:ci (Frontend)" -Action {
            npm run test:ci -- --no-progress
        }
    }
}
finally {
    Pop-Location
}

Write-Host "[verify] All steps finished." -ForegroundColor Green

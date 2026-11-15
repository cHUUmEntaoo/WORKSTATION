
# ============================================================
# WORKSTATION - Core Software Installer
# Windows 11 | PowerShell 7 | WinGet
# ============================================================

[CmdletBinding()]
param(
    [switch]$Install
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "        WORKSTATION - CORE SETUP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 1. Verify WinGet
# ------------------------------------------------------------

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "WinGet is not installed or available in PATH."
}

Write-Host "[OK] WinGet detected." -ForegroundColor Green

# ------------------------------------------------------------
# 2. Define core packages
# ------------------------------------------------------------

$packages = @(
    "Microsoft.PowerShell",
    "Microsoft.WindowsTerminal",
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "Mozilla.Firefox",
    "glzr-io.glazewm",
    "glzr-io.zebar",
    "JanDeDobbeleer.OhMyPosh",
    "DEVCOM.JetBrainsMonoNerdFont"
)

# ------------------------------------------------------------
# 3. Verify installed packages
# ------------------------------------------------------------

foreach ($package in $packages) {

    Write-Host ""
    Write-Host "Checking: $package" -ForegroundColor Cyan

    $result = & winget list `
        --id $package `
        --exact `
        --source winget `
        --disable-interactivity 2>&1 | Out-String

    $pattern = "(?m)^\s*.+\s+$([regex]::Escape($package))\s+\S+"

    $installed = [bool]($result -match $pattern)

    if ($installed) {
        Write-Host "[INSTALLED] $package" -ForegroundColor Green
        continue
    }

    Write-Host "[MISSING] $package" -ForegroundColor Yellow

    if ($Install) {

        Write-Host "Installing $package..." -ForegroundColor Cyan

        & winget install `
            --id $package `
            --exact `
            --source winget `
            --accept-package-agreements `
            --accept-source-agreements

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Installation failed: $package"
        }
        else {
            Write-Host "[OK] Installed: $package" -ForegroundColor Green
        }
    }
}

# ------------------------------------------------------------
# 4. Finish
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan

if ($Install) {
    Write-Host "Installation process finished." -ForegroundColor Green
}
else {
    Write-Host "Verification completed. No changes made." -ForegroundColor Green
}

Write-Host "==========================================" -ForegroundColor Cyan


# ============================================================
# WORKSTATION - PowerShell & Oh My Posh Restore
# Windows 11 | PowerShell 7
# ============================================================

[CmdletBinding()]
param(
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# 1. Verify PowerShell version
# ------------------------------------------------------------

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "PowerShell 7 or newer is required."
}

# ------------------------------------------------------------
# 2. Define paths
# ------------------------------------------------------------

$repo = (Resolve-Path -LiteralPath (
    Join-Path $PSScriptRoot "..\.."
)).Path

$sourceTheme = Join-Path $repo "configs\powershell\ohmyposh\theme.omp.json"

$sourceProfile = Join-Path $repo "configs\powershell\Microsoft.PowerShell_profile.ps1"

$targetTheme = Join-Path $HOME ".config\workstation\ohmyposh\theme.omp.json"

$targetProfile = $PROFILE.CurrentUserCurrentHost

$backupRoot = Join-Path $HOME ".config\workstation\backups\powershell"

$components = @(
    [PSCustomObject]@{
        Name   = "Oh My Posh Theme"
        Source = $sourceTheme
        Target = $targetTheme
    },
    [PSCustomObject]@{
        Name   = "PowerShell Profile"
        Source = $sourceProfile
        Target = $targetProfile
    }
)

# ------------------------------------------------------------
# 3. Header
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WORKSTATION - POWERSHELL RESTORE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 4. Verify repository files
# ------------------------------------------------------------

foreach ($component in $components) {

    if (-not (Test-Path -LiteralPath $component.Source -PathType Leaf)) {
        throw "Source not found: $($component.Source)"
    }

    Write-Host "[OK] Found: $($component.Name)" -ForegroundColor Green
}

# Validate Oh My Posh theme
Get-Content -LiteralPath $sourceTheme -Raw |
    ConvertFrom-Json -ErrorAction Stop |
    Out-Null

Write-Host "[OK] Oh My Posh JSON is valid." -ForegroundColor Green

# ------------------------------------------------------------
# 5. Compare files
# ------------------------------------------------------------

$changes = @()

foreach ($component in $components) {

    if (-not (Test-Path -LiteralPath $component.Target -PathType Leaf)) {

        Write-Host "[MISSING] $($component.Name)" -ForegroundColor Yellow

        $changes += $component
        continue
    }

    $sourceHash = (
        Get-FileHash -LiteralPath $component.Source -Algorithm SHA256
    ).Hash

    $targetHash = (
        Get-FileHash -LiteralPath $component.Target -Algorithm SHA256
    ).Hash

    if ($sourceHash -eq $targetHash) {

        Write-Host "[OK] $($component.Name) matches." -ForegroundColor Green

    }
    else {

        Write-Host "[DIFFERENT] $($component.Name)" -ForegroundColor Yellow

        $changes += $component
    }
}

# ------------------------------------------------------------
# 6. Nothing to restore
# ------------------------------------------------------------

if ($changes.Count -eq 0) {

    Write-Host ""
    Write-Host "[OK] All configurations already match." -ForegroundColor Green
    Write-Host "No restoration needed."

    return
}

# ------------------------------------------------------------
# 7. Preview mode
# ------------------------------------------------------------

if (-not $Apply) {

    Write-Host ""
    Write-Host "[PREVIEW] Files requiring restoration:"

    foreach ($component in $changes) {

        Write-Host ""
        Write-Host "Component: $($component.Name)"
        Write-Host "Source:    $($component.Source)"
        Write-Host "Target:    $($component.Target)"
    }

    Write-Host ""
    Write-Host "No changes made." -ForegroundColor Green
    Write-Host "Use -Apply to restore after review."

    return
}

# ------------------------------------------------------------
# 8. Backup existing files
# ------------------------------------------------------------

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"

$backupSession = Join-Path $backupRoot $timestamp

foreach ($component in $changes) {

    if (Test-Path -LiteralPath $component.Target -PathType Leaf) {

        New-Item -ItemType Directory `
            -Path $backupSession -Force | Out-Null

        $backupFile = Join-Path $backupSession (
            Split-Path $component.Target -Leaf
        )

        Copy-Item `
            -LiteralPath $component.Target `
            -Destination $backupFile `
            -ErrorAction Stop

        Write-Host "[BACKUP] $backupFile" -ForegroundColor Green
    }
}

# ------------------------------------------------------------
# 9. Restore configurations
# ------------------------------------------------------------

foreach ($component in $changes) {

    $targetDir = Split-Path $component.Target -Parent

    New-Item -ItemType Directory `
        -Path $targetDir -Force | Out-Null

    Copy-Item `
        -LiteralPath $component.Source `
        -Destination $component.Target `
        -Force `
        -ErrorAction Stop

    Write-Host "[RESTORED] $($component.Name)" -ForegroundColor Green
}

# ------------------------------------------------------------
# 10. Finish
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " POWERSHELL RESTORATION COMPLETED" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Open a new PowerShell 7 session to load the profile."

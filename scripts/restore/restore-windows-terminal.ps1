
# ============================================================
# WORKSTATION - Windows Terminal Configuration Restore
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

$source = Join-Path $repo (
    "configs\windows-terminal\settings.json"
)

$targetDir = Join-Path $env:LOCALAPPDATA (
    "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
)

$target = Join-Path $targetDir "settings.json"

$backupDir = Join-Path $HOME (
    ".config\workstation\backups\windows-terminal"
)

# ------------------------------------------------------------
# 3. Header
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WORKSTATION - WINDOWS TERMINAL RESTORE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 4. Verify repository configuration
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Repository configuration not found: $source"
}

Write-Host "[OK] Repository configuration found." -ForegroundColor Green

# ------------------------------------------------------------
# 5. Validate JSON
# ------------------------------------------------------------

try {

    Get-Content -LiteralPath $source -Raw -ErrorAction Stop |
        ConvertFrom-Json -ErrorAction Stop |
        Out-Null

    Write-Host "[OK] Windows Terminal JSON is valid." -ForegroundColor Green

}
catch {

    throw "Invalid Windows Terminal configuration: $($_.Exception.Message)"
}

# ------------------------------------------------------------
# 6. Verify Windows Terminal location
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $targetDir -PathType Container)) {

    throw "Windows Terminal packaged configuration directory not found: $targetDir"

}

Write-Host "[OK] Windows Terminal directory found." -ForegroundColor Green

# ------------------------------------------------------------
# 7. Compare configurations
# ------------------------------------------------------------

$targetExists = Test-Path -LiteralPath $target -PathType Leaf

if ($targetExists) {

    $sourceHash = (
        Get-FileHash -LiteralPath $source -Algorithm SHA256
    ).Hash

    $targetHash = (
        Get-FileHash -LiteralPath $target -Algorithm SHA256
    ).Hash

    if ($sourceHash -eq $targetHash) {

        Write-Host "[OK] Windows Terminal configuration matches." -ForegroundColor Green
        Write-Host ""
        Write-Host "No restoration needed."

        return
    }

    Write-Host "[DIFFERENT] Configuration differs." -ForegroundColor Yellow

}
else {

    Write-Host "[MISSING] Windows Terminal settings.json." -ForegroundColor Yellow

}

# ------------------------------------------------------------
# 8. Preview mode
# ------------------------------------------------------------

if (-not $Apply) {

    Write-Host ""
    Write-Host "[PREVIEW] Configuration requiring restoration:"
    Write-Host ""
    Write-Host "Source: $source"
    Write-Host "Target: $target"

    if ($targetExists) {
        Write-Host "[PREVIEW] Existing settings will be backed up."
    }
    else {
        Write-Host "[PREVIEW] No existing settings file to back up."
    }

    Write-Host ""
    Write-Host "No changes made." -ForegroundColor Green
    Write-Host "Use -Apply only after reviewing the configuration."

    return
}

# ------------------------------------------------------------
# 9. Backup existing configuration
# ------------------------------------------------------------

if ($targetExists) {

    New-Item `
        -ItemType Directory `
        -Path $backupDir `
        -Force | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"

    $backup = Join-Path $backupDir (
        "settings-$timestamp.json"
    )

    Copy-Item `
        -LiteralPath $target `
        -Destination $backup `
        -ErrorAction Stop

    # Verify that the backup is identical.
    $backupHash = (
        Get-FileHash -LiteralPath $backup -Algorithm SHA256
    ).Hash

    if ($backupHash -ne $targetHash) {
        throw "Backup verification failed. Restoration cancelled."
    }

    Write-Host "[BACKUP] $backup" -ForegroundColor Green
}

# ------------------------------------------------------------
# 10. Restore configuration
# ------------------------------------------------------------

Copy-Item `
    -LiteralPath $source `
    -Destination $target `
    -Force `
    -ErrorAction Stop

# ------------------------------------------------------------
# 11. Verify restoration
# ------------------------------------------------------------

$restoredHash = (
    Get-FileHash -LiteralPath $target -Algorithm SHA256
).Hash

$sourceHash = (
    Get-FileHash -LiteralPath $source -Algorithm SHA256
).Hash

if ($restoredHash -ne $sourceHash) {
    throw "Restoration verification failed."
}

Write-Host ""
Write-Host "[OK] Windows Terminal configuration restored." -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WINDOWS TERMINAL RESTORATION COMPLETED" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Review Windows Terminal after restoration."

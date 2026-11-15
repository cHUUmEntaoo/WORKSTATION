
# ============================================================
# WORKSTATION - GlazeWM Configuration Restore
# Windows 11 | PowerShell 7
# ============================================================

[CmdletBinding()]
param(
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# 1. Define paths
# ------------------------------------------------------------

$repo = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

$source = Join-Path $repo "configs\glazewm\config.yaml"

$targetDir = Join-Path $HOME ".glzr\glazewm"

$target = Join-Path $targetDir "config.yaml"

$backupDir = Join-Path $HOME ".config\workstation\backups\glazewm"

# ------------------------------------------------------------
# 2. Header
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    WORKSTATION - GLAZEWM RESTORE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 3. Verify repository configuration
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Repository configuration not found: $source"
}

Write-Host "[OK] Repository configuration found." -ForegroundColor Green

# ------------------------------------------------------------
# 4. Compare configurations
# ------------------------------------------------------------

if (Test-Path -LiteralPath $target -PathType Leaf) {

    $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash

    $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash

    if ($sourceHash -eq $targetHash) {
        Write-Host "[OK] Configuration already matches." -ForegroundColor Green
        Write-Host "No restoration needed."
        return
    }

    Write-Host "[INFO] Existing configuration is different." -ForegroundColor Yellow
}
else {
    Write-Host "[INFO] No existing GlazeWM configuration." -ForegroundColor Yellow
}

# ------------------------------------------------------------
# 5. Preview mode
# ------------------------------------------------------------

if (-not $Apply) {

    Write-Host ""
    Write-Host "[PREVIEW] Source: $source"
    Write-Host "[PREVIEW] Target: $target"
    Write-Host "[PREVIEW] Existing file will be backed up."
    Write-Host ""
    Write-Host "No changes made." -ForegroundColor Green

    return
}

# ------------------------------------------------------------
# 6. Backup existing configuration
# ------------------------------------------------------------

if (Test-Path -LiteralPath $target -PathType Leaf) {

    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"

    $backup = Join-Path $backupDir "config-$timestamp.yaml"

    Copy-Item -LiteralPath $target -Destination $backup -ErrorAction Stop

    Write-Host "[BACKUP] $backup" -ForegroundColor Green
}

# ------------------------------------------------------------
# 7. Restore configuration
# ------------------------------------------------------------

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

Copy-Item -LiteralPath $source -Destination $target -Force -ErrorAction Stop

Write-Host "[OK] GlazeWM configuration restored." -ForegroundColor Green
Write-Host "[INFO] GlazeWM was not automatically reloaded."

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "       RESTORATION COMPLETED" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

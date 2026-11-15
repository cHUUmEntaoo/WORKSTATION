
# ============================================================
# WORKSTATION - Zebar Configuration Restore
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

$sourceDir = Join-Path $repo "configs\zebar"

$targetDir = Join-Path $HOME ".glzr\zebar"

$backupDir = Join-Path $HOME ".config\workstation\backups\zebar"

$items = @(
    "settings.json",
    "workstation-bar"
)

# ------------------------------------------------------------
# 2. Header
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      WORKSTATION - ZEBAR RESTORE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 3. Verify repository files
# ------------------------------------------------------------

foreach ($item in $items) {

    $source = Join-Path $sourceDir $item

    if (-not (Test-Path -LiteralPath $source)) {
        throw "Repository item not found: $source"
    }

    Write-Host "[OK] Repository item found: $item" -ForegroundColor Green
}

# ------------------------------------------------------------
# 4. Compare directory contents
# ------------------------------------------------------------

function Get-DirectoryFingerprint {

    param(
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    $rootPath = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')

    @(
        Get-ChildItem -LiteralPath $Path -File -Recurse |
            ForEach-Object {

                $relative = $_.FullName.Substring($rootPath.Length).TrimStart('\')

                $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash

                "$relative|$hash"
            } |
            Sort-Object
    )
}

$changes = @()

foreach ($item in $items) {

    $source = Join-Path $sourceDir $item
    $target = Join-Path $targetDir $item

    if (-not (Test-Path -LiteralPath $target)) {
        $changes += $item
        Write-Host "[MISSING] $item" -ForegroundColor Yellow
        continue
    }

    if (Test-Path -LiteralPath $source -PathType Leaf) {

        $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
        $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash

        $same = $sourceHash -eq $targetHash
    }
    else {

        $sourceFiles = @(Get-DirectoryFingerprint -Path $source)
        $targetFiles = @(Get-DirectoryFingerprint -Path $target)

        $same = (
            (Compare-Object -ReferenceObject $sourceFiles -DifferenceObject $targetFiles).Count -eq 0
        )
    }

    if ($same) {
        Write-Host "[OK] $item matches." -ForegroundColor Green
    }
    else {
        $changes += $item
        Write-Host "[DIFFERENT] $item" -ForegroundColor Yellow
    }
}

# ------------------------------------------------------------
# 5. Stop if nothing needs restoration
# ------------------------------------------------------------

if ($changes.Count -eq 0) {

    Write-Host ""
    Write-Host "[OK] Zebar configuration already matches." -ForegroundColor Green
    Write-Host "No restoration needed."

    return
}

# ------------------------------------------------------------
# 6. Preview
# ------------------------------------------------------------

if (-not $Apply) {

    Write-Host ""
    Write-Host "[PREVIEW] Source: $sourceDir"
    Write-Host "[PREVIEW] Target: $targetDir"
    Write-Host "[PREVIEW] Items requiring restoration:"

    foreach ($item in $changes) {
        Write-Host "  - $item"
    }

    Write-Host ""
    Write-Host "No changes made." -ForegroundColor Green

    return
}

# ------------------------------------------------------------
# 7. Backup and restore
# ------------------------------------------------------------

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"

foreach ($item in $changes) {

    $source = Join-Path $sourceDir $item
    $target = Join-Path $targetDir $item

    if (Test-Path -LiteralPath $target) {

        $backup = Join-Path $backupDir "$timestamp\$item"

        $backupParent = Split-Path -Parent $backup

        New-Item -ItemType Directory -Path $backupParent -Force | Out-Null

        Copy-Item -LiteralPath $target -Destination $backup -Recurse -Force

        Write-Host "[BACKUP] $backup" -ForegroundColor Green

        Remove-Item -LiteralPath $target -Recurse -Force
    }

    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force

    Write-Host "[RESTORED] $item" -ForegroundColor Green
}

Write-Host ""
Write-Host "[OK] Zebar configuration restored." -ForegroundColor Green
Write-Host "[INFO] Zebar was not automatically restarted."

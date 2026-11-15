
# ============================================================
# WORKSTATION - RELEASE CHECK v1.0
# Windows 11 | PowerShell 7
# ============================================================

[CmdletBinding()]
param(
    [switch]$Snapshot
)

$ErrorActionPreference = "Stop"

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "PowerShell 7 or newer is required."
}

$repo = (Resolve-Path (
    Join-Path $PSScriptRoot "..\.."
)).Path

$backupRoot = Join-Path $HOME ".config\workstation\backups"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WORKSTATION - RELEASE CHECK v1.0" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Configuration inventory
# ------------------------------------------------------------

$items = @(
    @{
        Name = "GlazeWM"
        Live = "$HOME\.glzr\glazewm\config.yaml"
        Repo = "$repo\configs\glazewm\config.yaml"
        Path = "glazewm\config.yaml"
    },
    @{
        Name = "Zebar Settings"
        Live = "$HOME\.glzr\zebar\settings.json"
        Repo = "$repo\configs\zebar\settings.json"
        Path = "zebar\settings.json"
    },
    @{
        Name = "WORKSTATION-BAR"
        Live = "$HOME\.glzr\zebar\workstation-bar"
        Repo = "$repo\configs\zebar\workstation-bar"
        Path = "zebar\workstation-bar"
    },
    @{
        Name = "Oh My Posh"
        Live = "$HOME\.config\workstation\ohmyposh\theme.omp.json"
        Repo = "$repo\configs\powershell\ohmyposh\theme.omp.json"
        Path = "powershell\theme.omp.json"
    },
    @{
        Name = "PowerShell Profile"
        Live = $PROFILE.CurrentUserCurrentHost
        Repo = "$repo\configs\powershell\Microsoft.PowerShell_profile.ps1"
        Path = "powershell\Microsoft.PowerShell_profile.ps1"
    },
    @{
        Name = "Windows Terminal"
        Live = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        Repo = "$repo\configs\windows-terminal\settings.json"
        Path = "windows-terminal\settings.json"
    }
)

# ------------------------------------------------------------
# 2. Fingerprint calculation
# ------------------------------------------------------------

function Get-Fingerprint {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return @(
            (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
        )
    }

    $root = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')

    return @(
        Get-ChildItem -LiteralPath $Path -Recurse -File |
            ForEach-Object {
                $relative = $_.FullName.Substring($root.Length).TrimStart('\')
                $hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
                "$relative|$hash"
            } |
            Sort-Object
    )
}

function Test-SameContent {
    param(
        [string]$First,
        [string]$Second
    )

    if (-not (Test-Path -LiteralPath $First)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $Second)) {
        return $false
    }

    $a = @(Get-Fingerprint -Path $First)
    $b = @(Get-Fingerprint -Path $Second)

    return (
        @(Compare-Object -ReferenceObject $a -DifferenceObject $b).Count -eq 0
    )
}

# ------------------------------------------------------------
# 3. Compare active configurations
# ------------------------------------------------------------

$failures = 0

Write-Host ""
Write-Host "[1] CONFIGURATION CHECK" -ForegroundColor Cyan

foreach ($item in $items) {
    if (Test-SameContent -First $item.Live -Second $item.Repo) {
        Write-Host "[OK] $($item.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "[CHECK] $($item.Name) differs or is missing." -ForegroundColor Yellow
        $failures++
    }
}

# ------------------------------------------------------------
# 4. Validate all PowerShell scripts
# ------------------------------------------------------------

Write-Host ""
Write-Host "[2] POWERSHELL SCRIPT VALIDATION" -ForegroundColor Cyan

$scripts = @(Get-ChildItem "$repo\scripts" -Recurse -Filter "*.ps1" -File)

foreach ($script in $scripts) {
    $tokens = $null
    $errorsFound = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        $script.FullName,
        [ref]$tokens,
        [ref]$errorsFound
    ) | Out-Null

    if ($errorsFound.Count -eq 0) {
        Write-Host "[OK] $($script.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] $($script.Name)" -ForegroundColor Red
        $failures++
    }
}

# ------------------------------------------------------------
# 5. Check automatic startup
# ------------------------------------------------------------

Write-Host ""
Write-Host "[3] AUTOMATIC STARTUP" -ForegroundColor Cyan

$startupFolder = [Environment]::GetFolderPath(
    [Environment+SpecialFolder]::Startup
)

$link = Join-Path $startupFolder "WORKSTATION-GlazeWM.lnk"

if (Test-Path -LiteralPath $link) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($link)

    if (Test-Path -LiteralPath $shortcut.TargetPath) {
        Write-Host "[OK] GlazeWM startup shortcut" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Startup shortcut target missing." -ForegroundColor Red
        $failures++
    }
}
else {
    Write-Host "[ERROR] GlazeWM startup shortcut missing." -ForegroundColor Red
    $failures++
}

$glazewmConfig = "$HOME\.glzr\glazewm\config.yaml"

if (Select-String -LiteralPath $glazewmConfig -Pattern "shell-exec zebar" -Quiet) {
    Write-Host "[OK] Zebar startup configured" -ForegroundColor Green
}
else {
    Write-Host "[ERROR] Zebar startup not found." -ForegroundColor Red
    $failures++
}

# ------------------------------------------------------------
# 6. Abort snapshot if checks fail
# ------------------------------------------------------------

if ($failures -gt 0) {
    Write-Host ""
    Write-Host "Release check found $failures issue(s)." -ForegroundColor Yellow
    throw "Review issues before creating the release snapshot."
}

# ------------------------------------------------------------
# 7. Optional live configuration snapshot
# ------------------------------------------------------------

if ($Snapshot) {
    Write-Host ""
    Write-Host "[4] CREATING CONFIGURATION SNAPSHOT" -ForegroundColor Cyan

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"

    $snapshotDir = Join-Path $backupRoot "release-v1-$timestamp"

    foreach ($item in $items) {
        $destination = Join-Path $snapshotDir $item.Path

        $parent = Split-Path $destination -Parent

        New-Item -ItemType Directory -Path $parent -Force | Out-Null

        Copy-Item `
            -LiteralPath $item.Live `
            -Destination $destination `
            -Recurse `
            -Force `
            -ErrorAction Stop

        if (-not (Test-SameContent -First $item.Live -Second $destination)) {
            throw "Snapshot verification failed: $($item.Name)"
        }

        Write-Host "[BACKUP OK] $($item.Name)" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Snapshot saved at:" -ForegroundColor Cyan
    Write-Host $snapshotDir
}

# ------------------------------------------------------------
# 8. Finish
# ------------------------------------------------------------

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WORKSTATION RELEASE CHECK PASSED" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configurations verified: $($items.Count)"
Write-Host "PowerShell scripts checked: $($scripts.Count)"
Write-Host "Issues found: $failures"

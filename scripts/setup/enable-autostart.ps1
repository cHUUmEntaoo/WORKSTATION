
# ============================================================
# WORKSTATION - Automatic Startup Setup
# Windows 11 | PowerShell 7
# ============================================================

[CmdletBinding()]
param(
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WORKSTATION - AUTOMATIC STARTUP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Locate GlazeWM executable
$command = Get-Command glazewm.exe -ErrorAction SilentlyContinue

if (-not $command) {
    throw "GlazeWM executable not found in PATH."
}

$exe = $command.Source

# Current-user Windows Startup folder
$startupFolder = [Environment]::GetFolderPath(
    [Environment+SpecialFolder]::Startup
)

$shortcutPath = Join-Path $startupFolder "WORKSTATION-GlazeWM.lnk"

Write-Host ""
Write-Host "[OK] GlazeWM: $exe" -ForegroundColor Green
Write-Host "[INFO] Startup folder: $startupFolder"

# Verify existing shortcut
if (Test-Path -LiteralPath $shortcutPath) {
    Write-Host "[OK] WORKSTATION startup shortcut already exists." -ForegroundColor Green
    return
}

# Detect other GlazeWM autostart registrations
$existing = @(
    Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Command -match '(?i)glazewm'
    }
)

if ($existing.Count -gt 0) {
    Write-Warning "GlazeWM already has a startup registration. No duplicate created."
    $existing | Select-Object Name, Command, Location
    return
}

# Preview mode
if (-not $Apply) {
    Write-Host ""
    Write-Host "[PREVIEW] Shortcut: $shortcutPath"
    Write-Host "[PREVIEW] Target: $exe"
    Write-Host "No changes made." -ForegroundColor Green
    return
}

# Create startup shortcut for current user
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)

$shortcut.TargetPath = $exe
$shortcut.WorkingDirectory = Split-Path -Path $exe -Parent
$shortcut.Description = "WORKSTATION - GlazeWM Auto Startup"
$shortcut.IconLocation = $exe

$shortcut.Save()

# Verify result
if (-not (Test-Path -LiteralPath $shortcutPath)) {
    throw "Could not create startup shortcut."
}

Write-Host ""
Write-Host "[OK] GlazeWM automatic startup enabled." -ForegroundColor Green
Write-Host "[INFO] Zebar is started through GlazeWM configuration."
Write-Host "[INFO] Changes take effect at next Windows sign-in."

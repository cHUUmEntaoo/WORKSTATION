# WORKSTATION NOCTURNE - DESKTOP DOCK / RED TEAM v1.1
# Run in the WORKSTATION Windows 11 account (not as administrator).
# Purpose: dock behind other windows, reserved 60px lane, wallpaper,
#          shareable theme and public installer fixes.
# Optional -Publish: commit/push only the files created or edited here.
[CmdletBinding()]
param(
    [switch]$Publish,
    [switch]$SkipWallpaper
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = Join-Path $HOME 'Projects\WORKSTATION'
$release = Join-Path $repo 'WORKSTATION-NOCTURNE'
$glaze = Join-Path $HOME '.glzr\glazewm\config.yaml'
$dock = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins\WORKSTATION\Dock\Dock.ini'
$publicDock = Join-Path $release 'theme\rainmeter\WORKSTATION\Dock\Dock.ini'
$publicGlaze = Join-Path $release 'theme\glazewm\config.yaml'
$publicInstaller = Join-Path $release 'install.ps1'
$readme = Join-Path $release 'README.md'
$rainmeterSettings = Join-Path $env:APPDATA 'Rainmeter\Rainmeter.ini'
$layoutSettings = Join-Path $env:APPDATA 'Rainmeter\Layouts\WORKSTATION-NOCTURNE\Rainmeter.ini'
$wallpaperSource = Join-Path $PSScriptRoot 'NOCTURNE-REDTEAM.png'
if (-not (Test-Path -LiteralPath $wallpaperSource -PathType Leaf)) {
    $wallpaperSource = Join-Path $release 'theme\wallpaper\nocturne-redteam.png'
}
$wallpaperDestination = Join-Path $HOME 'Pictures\WORKSTATION\NOCTURNE-REDTEAM.png'
$publicWallpaper = Join-Path $release 'theme\wallpaper\nocturne-redteam.png'
$scriptDestination = Join-Path $release 'repair-desktop.ps1'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = Join-Path $HOME ".config\workstation\backups\nocturne-desktop-$stamp"
$utf8 = New-Object System.Text.UTF8Encoding($false)

$rmCandidates = @(
    (Join-Path $env:ProgramFiles 'Rainmeter\Rainmeter.exe'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Rainmeter\Rainmeter.exe')
)
$rainmeter = $rmCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1

# Check before making changes.
foreach ($f in @($glaze, $dock, $publicDock, $publicGlaze, $publicInstaller, $readme)) {
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { throw "Required file not found: $f" }
}
if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) { throw "Git repository not found: $repo" }
if (-not $rainmeter) { throw 'Rainmeter.exe not found; installation was not changed.' }
if (-not $SkipWallpaper -and -not (Test-Path -LiteralPath $wallpaperSource -PathType Leaf)) {
    throw "Wallpaper image not found: $wallpaperSource"
}
if ($Publish) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is not installed or not in PATH.' }
    $oldStaged = @(git -C $repo diff --cached --name-only)
    if ($LASTEXITCODE -ne 0) { throw 'Could not check staged Git changes.' }
    if ($oldStaged.Count -gt 0) { throw 'There are already staged files. Commit or unstage those changes before using -Publish.' }
}

New-Item -ItemType Directory -Force -Path $backup | Out-Null
function Backup-File([string]$Path, [string]$Name) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $destination = Join-Path $backup $Name
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $Path -Destination $destination -Force
    }
}
function Read-Text([string]$Path) { return [System.IO.File]::ReadAllText($Path) }
function Write-Text([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}
function Set-DockDesktop([string]$Path) {
    $original = Read-Text $Path
    if (-not [regex]::IsMatch($original, '(?m)^DefaultAlwaysOnTop\s*=')) {
        throw "Expected DefaultAlwaysOnTop setting missing: $Path"
    }
    $updated = [regex]::Replace($original, '(?m)^DefaultAlwaysOnTop\s*=\s*[^\r\n]*', 'DefaultAlwaysOnTop=-2')
    if ($updated -ne $original) { Write-Text $Path $updated }
}
function Set-GlazeDockGap([string]$Path) {
    $original = Read-Text $Path
    $match = [regex]::Match($original, '(?ms)^gaps:[^\r\n]*\r?\n.*?(?=^[A-Za-z_][A-Za-z0-9_]*\s*:|\z)')
    if (-not $match.Success) { throw "GlazeWM gaps block not found: $Path" }
    $block = $match.Value
    if (-not [regex]::IsMatch($block, '(?m)^\s+left\s*:')) { throw "GlazeWM left gap not found: $Path" }
    $newBlock = [regex]::Replace($block, '(?m)^([ \t]+left)[ \t]*:[ \t]*[^\r\n]*', '${1}: ''60px''')
    $updated = $original.Substring(0, $match.Index) + $newBlock + $original.Substring($match.Index + $match.Length)
    if ($updated -ne $original) { Write-Text $Path $updated }
}

Write-Host '[1/5] Backing up current settings...' -ForegroundColor Cyan
Backup-File $glaze 'glazewm-config.yaml'
Backup-File $dock 'dock-live.ini'
Backup-File $publicDock 'dock-repository.ini'
Backup-File $publicGlaze 'glazewm-repository.yaml'
Backup-File $publicInstaller 'install-repository.ps1'
Backup-File $readme 'README-repository.md'
Backup-File $rainmeterSettings 'Rainmeter.ini'
Backup-File $layoutSettings 'Layout-Rainmeter.ini'
Backup-File $publicWallpaper 'wallpaper-repository.png'
Backup-File $wallpaperDestination 'wallpaper-user-previous.png'
Backup-File $scriptDestination 'repair-desktop-previous.ps1'

Write-Host '[2/5] Moving the dock to the desktop layer...' -ForegroundColor Cyan
Set-DockDesktop $dock
Set-DockDesktop $publicDock
Set-GlazeDockGap $glaze
Set-GlazeDockGap $publicGlaze

# Make future installations respect desktop z-order even if the user had
# previously loaded the Rainmeter dock and Rainmeter.ini overrides defaults.
$installerText = Read-Text $publicInstaller
$activateLine = "& `$rainmeter '!ActivateConfig' 'WORKSTATION\Dock' 'Dock.ini' | Out-Null"
$zposLine = "    & `$rainmeter '!ZPos' '-2' 'WORKSTATION\Dock' | Out-Null"
if ($installerText -notmatch "(?m)'!ZPos'\s+'-2'\s+'WORKSTATION\\Dock'") {
    if (-not $installerText.Contains($activateLine)) {
        throw 'Public installer has changed; could not safely patch Rainmeter z-order. Settings are backed up.'
    }
    $installerText = $installerText.Replace($activateLine, "$activateLine`r`n$zposLine")
}
# Use the delivered Red Team image for the public installer wallpaper option.
if (-not $SkipWallpaper) {
    $installerText = $installerText.Replace("'wallpaper\nocturne-original.png'", "'wallpaper\nocturne-redteam.png'")
}
Write-Text $publicInstaller $installerText

Write-Host '[3/5] Updating the wallpaper and public kit...' -ForegroundColor Cyan
if (-not $SkipWallpaper) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $wallpaperDestination) | Out-Null
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $publicWallpaper) | Out-Null
    Copy-Item -LiteralPath $wallpaperSource -Destination $wallpaperDestination -Force
    if ([System.IO.Path]::GetFullPath($wallpaperSource) -ne [System.IO.Path]::GetFullPath($publicWallpaper)) {
        Copy-Item -LiteralPath $wallpaperSource -Destination $publicWallpaper -Force
    }
    # Fill the screen. Preserve the old wallpaper path for rollback.
    $desktopSettings = Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop'
    $previous = $desktopSettings.Wallpaper
    [System.IO.File]::WriteAllLines((Join-Path $backup 'previous-wallpaper-settings.txt'), [string[]]@(
        "Path=$previous", "Style=$($desktopSettings.WallpaperStyle)", "Tile=$($desktopSettings.TileWallpaper)"))
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10'
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'
    if (-not ('NocturneWallpaperAPI' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class NocturneWallpaperAPI {
    [DllImport("user32.dll", CharSet=CharSet.Unicode)]
    public static extern bool SystemParametersInfo(uint action, uint param, string file, uint flags);
}
'@
    }
    if (-not [NocturneWallpaperAPI]::SystemParametersInfo(20, 0, $wallpaperDestination, 3)) {
        Write-Warning 'Windows could not apply the wallpaper automatically; the image was copied to Pictures\WORKSTATION.'
    }
}
if ([System.IO.Path]::GetFullPath($PSCommandPath) -ne [System.IO.Path]::GetFullPath($scriptDestination)) {
    Copy-Item -LiteralPath $PSCommandPath -Destination $scriptDestination -Force
}
$readmeText = Read-Text $readme
if ($readmeText -notmatch 'DESKTOP DOCK / RED TEAM V1.1') {
    $readmeText += @'

## DESKTOP DOCK / RED TEAM V1.1

The left Rainmeter dock uses **On desktop** (`DefaultAlwaysOnTop=-2`) and
GlazeWM reserves a **60px left rail**. This keeps the dock accessible beside
tiled windows without covering application content. The panels (Operations,
Control Center and Launcher) intentionally open above applications temporarily.

For an existing installation, run `repair-desktop.ps1` from PowerShell
within this repository, or use the `NOCTURNE_DESKTOP_FIX.zip` distribution. This backs up
live and repository files before making changes. The optional `-Publish` flag
commits only the Nocturne files changed by this repair to your GitHub remote.
The included wallpaper is an original Red Team image. When cloning, use
`install.ps1 -ApplyGlazeWM -SetWallpaper` only if you agree to replacing your
existing GlazeWM keybindings (the installer creates a backup).
'@
    Write-Text $readme $readmeText
}

Write-Host '[4/5] Applying settings to running programs...' -ForegroundColor Cyan
if (-not (Get-Process -Name Rainmeter -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $rainmeter
    Start-Sleep -Seconds 2
}
& $rainmeter '!RefreshApp' | Out-Null
Start-Sleep -Milliseconds 650
& $rainmeter '!DeactivateConfig' 'WORKSTATION\Operations' | Out-Null
& $rainmeter '!DeactivateConfig' 'WORKSTATION\ControlCenter' | Out-Null
& $rainmeter '!DeactivateConfig' 'WORKSTATION\Launcher' | Out-Null
& $rainmeter '!ActivateConfig' 'WORKSTATION\Dock' 'Dock.ini' | Out-Null
Start-Sleep -Milliseconds 600
& $rainmeter '!ZPos' '-2' 'WORKSTATION\Dock' | Out-Null
& $rainmeter '!Move' '0' '38' 'WORKSTATION\Dock' | Out-Null
Start-Sleep -Milliseconds 650

# Update the Rainmeter layout snapshot so reloading it won't restore topmost.
if ((Test-Path -LiteralPath $layoutSettings) -and (Test-Path -LiteralPath $rainmeterSettings)) {
    Copy-Item -LiteralPath $rainmeterSettings -Destination $layoutSettings -Force
    Write-Host '[OK] WORKSTATION-NOCTURNE layout snapshot updated.' -ForegroundColor Green
}
if (Get-Command glazewm -ErrorAction SilentlyContinue) {
    $result = (& glazewm command wm-reload-config 2>&1 | Out-String)
    Write-Host $result.Trim()
    if ($result -match '"success"\s*:\s*false') {
        Copy-Item -LiteralPath (Join-Path $backup 'glazewm-config.yaml') -Destination $glaze -Force
        & glazewm command wm-reload-config | Out-Null
        throw 'GlazeWM rejected the new gap configuration. Original GlazeWM configuration restored.'
    }
    & glazewm command wm-redraw | Out-Null
}

Write-Host '[5/5] Result and optional publication...' -ForegroundColor Cyan
Write-Host '[OK] Dock on desktop (-2), NOT always on top.' -ForegroundColor Green
Write-Host '[OK] GlazeWM reserves 60px for the dock.' -ForegroundColor Green
Write-Host '[OK] Operations, Control Center and Launcher remain clickable.' -ForegroundColor Green
Write-Host "[BACKUP] $backup"

if ($Publish) {
    $files = @(
        'WORKSTATION-NOCTURNE/repair-desktop.ps1',
        'WORKSTATION-NOCTURNE/install.ps1',
        'WORKSTATION-NOCTURNE/README.md',
        'WORKSTATION-NOCTURNE/theme/glazewm/config.yaml',
        'WORKSTATION-NOCTURNE/theme/rainmeter/WORKSTATION/Dock/Dock.ini'
    )
    if (-not $SkipWallpaper) { $files += 'WORKSTATION-NOCTURNE/theme/wallpaper/nocturne-redteam.png' }
    & git -C $repo add -- $files
    if ($LASTEXITCODE -ne 0) { throw 'git add failed. Nothing was pushed.' }
    & git -C $repo diff --cached --check
    if ($LASTEXITCODE -ne 0) { throw 'Git whitespace validation failed. Nothing was pushed.' }
    & git -C $repo diff --cached --stat
    $stagedFiles = @(git -C $repo diff --cached --name-only)
    if ($LASTEXITCODE -ne 0) { throw 'git diff failed. Nothing was pushed.' }
    if ($stagedFiles.Count -gt 0) {
        & git -C $repo commit -m 'fix: desktop-layer dock and Red Team wallpaper'
        if ($LASTEXITCODE -ne 0) { throw 'Commit failed. Nothing was pushed.' }
        & git -C $repo push origin main
        if ($LASTEXITCODE -ne 0) { throw 'Push failed. Local commit remains available.' }
        Write-Host '[GITHUB] Update published successfully.' -ForegroundColor Green
    }
    else { Write-Host '[GITHUB] No new changes to publish.' -ForegroundColor Green }
    & git -C $repo status -sb
}
Write-Host 'NOCTURNE DESKTOP DOCK: COMPLETED.' -ForegroundColor Cyan

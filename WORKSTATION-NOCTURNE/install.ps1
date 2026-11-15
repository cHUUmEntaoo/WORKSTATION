# WORKSTATION NOCTURNE - public installer / Windows 11 / PowerShell 7 or 5.1
# Normal install: .\install.ps1
# Optional: .\install.ps1 -InstallApps -ApplyGlazeWM -SetWallpaper
# Existing settings are backed up, and neither WSL nor Docker are touched.
[CmdletBinding()]
param(
    [switch]$InstallApps,
    [switch]$ApplyGlazeWM,
    [switch]$SetWallpaper,
    [switch]$SkipZebar,
    [switch]$SkipRainmeter,
    [switch]$StartApps
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$theme=Join-Path $root 'theme'
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$backup=Join-Path $env:USERPROFILE ".config\workstation\backups\nocturne-$stamp"
$manifest=@()
New-Item -ItemType Directory -Force -Path $backup | Out-Null

# Scoped functions must append array in script scope explicitly.
function Add-Tracked([string]$From,[string]$To,[string]$Name) {
    if (-not (Test-Path -LiteralPath $From -PathType Leaf)) { throw "Missing source file: $From" }
    if (Test-Path -LiteralPath $To -PathType Leaf) {
        $save=Join-Path $backup $Name
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $save) | Out-Null
        Copy-Item -LiteralPath $To -Destination $save -Force
        $script:manifest += [PSCustomObject]@{ Target=$To; Backup=$save; Existed=$true }
    } else {
        $script:manifest += [PSCustomObject]@{ Target=$To; Backup=''; Existed=$false }
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $To) | Out-Null
    Copy-Item -LiteralPath $From -Destination $To -Force
    Write-Host "[OK] $Name" -ForegroundColor Green
}

if ($InstallApps) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {throw 'winget is missing; install Microsoft App Installer first.'}
    $packages=@('glzr-io.glazewm','glzr-io.zebar','Rainmeter.Rainmeter','Microsoft.WindowsTerminal')
    foreach($id in $packages) {
        Write-Host "Checking package: $id"
        & winget install --id $id --exact --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { Write-Warning "$id failed or requires interactive setup; check installation before continuing." }
    }
    Write-Host 'GlazeWM installer may offer Zebar as an optional component. Confirm Zebar is installed.'
}

$zebarDestination=Join-Path $env:USERPROFILE '.glzr\zebar\workstation-bar'
$rainmeterDestination=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins\WORKSTATION'
$glazeDestination=Join-Path $env:USERPROFILE '.glzr\glazewm\config.yaml'
if (-not $SkipZebar) {
    if (-not (Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.glzr\zebar'))) {
      Write-Warning 'Zebar config directory does not exist. Install / launch Zebar and choose WORKSTATION-BAR in its settings.'
    }
    foreach($name in @('with-glazewm.html','styles.css')) {
        Add-Tracked (Join-Path $theme "zebar\$name") (Join-Path $zebarDestination $name) "zebar\$name"
    }
    # Copy widget pack metadata only on a new installation. Preserve existing user metadata.
    $packJson=Join-Path $zebarDestination 'zpack.json'
    if (-not (Test-Path -LiteralPath $packJson)) {
        Add-Tracked (Join-Path $theme 'zebar\zpack.json') $packJson 'zebar\zpack.json'
    }
}
if (-not $SkipRainmeter) {
    Get-ChildItem -LiteralPath (Join-Path $theme 'rainmeter\WORKSTATION') -Recurse -File | ForEach-Object {
        $relative=$_.FullName.Substring((Join-Path $theme 'rainmeter\WORKSTATION').Length).TrimStart('\','/')
        Add-Tracked $_.FullName (Join-Path $rainmeterDestination $relative) "rainmeter\$relative"
    }
}
if ($ApplyGlazeWM) {
    # Explicit option to replace GlazeWM. Default installation preserves existing key bindings.
    Add-Tracked (Join-Path $theme 'glazewm\config.yaml') $glazeDestination 'glazewm\config.yaml'
}
if ($SetWallpaper) {
    $wallpaper=Join-Path $theme 'wallpaper\nocturne-original.png'
    # Save existing wallpaper path for manual restore (Windows stores wallpaper in multiple places).
    $current=(Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -ErrorAction SilentlyContinue).Wallpaper
    Set-Content -LiteralPath (Join-Path $backup 'previous-wallpaper-path.txt') -Value $current
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class WsWallpaper { [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern bool SystemParametersInfo(uint a,uint b,string c,uint d); }
'@
    if (-not [WsWallpaper]::SystemParametersInfo(20,0,$wallpaper,3)) { Write-Warning 'Wallpaper could not be applied.' }
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $backup 'manifest.json') -Encoding UTF8
Set-Content -LiteralPath (Join-Path $env:USERPROFILE '.config\workstation\nocturne-latest-backup.txt') -Value $backup -Encoding UTF8

# Rainmeter: refresh and load the dock. Pass each CLI argument separately.
# HOTFIX RC1.1: Rainmeter can mistake a whole quoted bang as a settings-path override.
$rainmeterCandidates=@(
  (Join-Path $env:ProgramFiles 'Rainmeter\Rainmeter.exe'),
  (Join-Path $env:LOCALAPPDATA 'Programs\Rainmeter\Rainmeter.exe')
)
$rainmeter=$rainmeterCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if ($rainmeter -and -not $SkipRainmeter) {
    if (-not (Get-Process Rainmeter -ErrorAction SilentlyContinue)) { Start-Process -FilePath $rainmeter; Start-Sleep -Seconds 2 }
    & $rainmeter '!RefreshApp' | Out-Null
    Start-Sleep -Milliseconds 700
    & $rainmeter '!DeactivateConfig' 'WORKSTATION\Operations' | Out-Null
    & $rainmeter '!DeactivateConfig' 'WORKSTATION\ControlCenter' | Out-Null
    & $rainmeter '!DeactivateConfig' 'WORKSTATION\Launcher' | Out-Null
    & $rainmeter '!ActivateConfig' 'WORKSTATION\Dock' 'Dock.ini' | Out-Null
}
if ($StartApps) {
    foreach($cmd in @('glazewm','zebar')) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) { Start-Process $cmd -ErrorAction SilentlyContinue }
    }
}
Write-Host ''
Write-Host 'WORKSTATION NOCTURNE: FILES INSTALLED' -ForegroundColor Cyan
Write-Host "Backup: $backup"
Write-Host 'Zebar: reload configs in the tray menu; Rainmeter: dock should appear.'
Write-Host 'To restore: .\restore.ps1 -BackupPath "<path above>"'
Write-Host 'For new machines: select WORKSTATION-BAR in Zebar settings and start GlazeWM.'

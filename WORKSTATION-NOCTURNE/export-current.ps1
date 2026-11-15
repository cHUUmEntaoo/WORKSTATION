# Run on the designer's computer BEFORE publishing to capture the actually tested UI.
# Does not export private Rainmeter settings, SSH keys or secrets.
[CmdletBinding()]
param([switch]$IncludeGlazeWM,[switch]$IncludeDock)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$theme=Join-Path $root 'theme'
$z=Join-Path $env:USERPROFILE '.glzr\zebar\workstation-bar'
$skins=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins\WORKSTATION'
foreach($name in @('with-glazewm.html','styles.css')) {
    $from=Join-Path $z $name
    if (-not (Test-Path -LiteralPath $from)) { throw "Missing: $from" }
    Copy-Item -LiteralPath $from -Destination (Join-Path $theme "zebar\$name") -Force
}
foreach($rel in @('Operations\Operations.ini','ControlCenter\ControlCenter.ini','ControlCenter\Calendar.lua','Launcher\Launcher.ini','@Resources\Scripts\WinPanel.ps1')) {
    $from=Join-Path $skins $rel
    if (Test-Path -LiteralPath $from) {
        $target=Join-Path (Join-Path $theme 'rainmeter\WORKSTATION') $rel
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
        Copy-Item -LiteralPath $from -Destination $target -Force
        Write-Host "[EXPORTED] $rel"
    } else {Write-Warning "Not found (keeping package version): $rel"}
}
if ($IncludeDock) {
    $source=Join-Path $skins 'Dock\Dock.ini'
    if(Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination (Join-Path $theme 'rainmeter\WORKSTATION\Dock\Dock.ini') -Force }
    Write-Warning 'Exporting your old Dock may replace the new Launcher button behavior. Review Dock.ini before publishing.'
}
if ($IncludeGlazeWM) {
    $from=Join-Path $env:USERPROFILE '.glzr\glazewm\config.yaml'
    if (-not (Test-Path -LiteralPath $from)) {throw "Not found: $from"}
    Copy-Item -LiteralPath $from -Destination (Join-Path $theme 'glazewm\config.yaml') -Force
    Write-Warning 'Review exported GlazeWM file for personal paths and secrets before Git push.'
}
Write-Host '[OK] Current UI copied to theme/. Review git diff before publishing.'

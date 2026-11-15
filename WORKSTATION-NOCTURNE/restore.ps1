# Restores only files changed by install.ps1 from a selected backup.
[CmdletBinding()]
param([string]$BackupPath)
$ErrorActionPreference='Stop'
if (-not $BackupPath) {
    $last=Join-Path $env:USERPROFILE '.config\workstation\nocturne-latest-backup.txt'
    if (-not (Test-Path -LiteralPath $last)) { throw 'No recorded backup. Supply -BackupPath.' }
    $BackupPath=(Get-Content -LiteralPath $last -Raw).Trim()
}
$manifestFile=Join-Path $BackupPath 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestFile)) { throw "Missing manifest: $manifestFile" }
$items=@(Get-Content -LiteralPath $manifestFile -Raw | ConvertFrom-Json)
Write-Host "Restore from: $BackupPath"
$answer=Read-Host 'Type RESTORE to continue'
if ($answer -cne 'RESTORE') {throw 'Restore cancelled.'}
foreach($item in $items) {
    if ($item.Existed) {
        if (-not (Test-Path -LiteralPath $item.Backup)) { throw "Backup missing: $($item.Backup)" }
        Copy-Item -LiteralPath $item.Backup -Destination $item.Target -Force
    } else {
        if (Test-Path -LiteralPath $item.Target -PathType Leaf) { Remove-Item -LiteralPath $item.Target -Force }
    }
    Write-Host "[RESTORED] $($item.Target)"
}
Write-Host 'Restart/reload Zebar and Rainmeter to see restored design.'

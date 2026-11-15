# Restore only files tracked by NOCTURNE COMMAND DECK V3.
[CmdletBinding()]
param([string]$BackupPath, [switch]$Force)
$ErrorActionPreference='Stop'
if(-not $BackupPath) {
  $pointer=Join-Path $HOME '.config\workstation\command-deck-v3-last.txt'
  if(-not(Test-Path -LiteralPath $pointer)){throw 'No se encontro el ultimo backup. Usa -BackupPath.'}
  $BackupPath=(Get-Content -LiteralPath $pointer -Raw).Trim()
}
$manifest=Join-Path $BackupPath 'manifest.json'
if(-not(Test-Path -LiteralPath $manifest)){throw "Manifest inexistente: $manifest"}
$items=@(Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json)
if (-not $Force) {
  Write-Host "Se restauraran $($items.Count) archivos desde: $BackupPath" -ForegroundColor Yellow
  $answer=Read-Host 'Escribe RESTORE para continuar'
  if($answer -cne 'RESTORE'){Write-Host 'Cancelado, sin cambios.'; return}
}
$failed=0
for ($i=$items.Count-1;$i -ge 0;$i--) {
  $item=$items[$i]
  try {
    if($item.Existed){
      if(-not(Test-Path -LiteralPath $item.Backup -PathType Leaf)){throw "Respaldo no disponible: $($item.Backup)"}
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $item.Target) | Out-Null
      Copy-Item -LiteralPath $item.Backup -Destination $item.Target -Force
    } else {
      if(Test-Path -LiteralPath $item.Target -PathType Leaf){ Remove-Item -LiteralPath $item.Target -Force }
    }
  } catch {$failed++;Write-Warning "No se pudo restaurar $($item.Target): $($_.Exception.Message)"}
}
if($failed){throw "Restauracion parcial. $failed archivo(s) fallaron."}
if(Get-Process -Name glazewm -ErrorAction SilentlyContinue){
  $result=(& glazewm command wm-reload-config 2>&1 | Out-String)
  Write-Host "GlazeWM: $result"
}
$rm=@((Join-Path $env:ProgramFiles 'Rainmeter\Rainmeter.exe'),(Join-Path $env:LOCALAPPDATA 'Programs\Rainmeter\Rainmeter.exe')) | Where-Object {Test-Path -LiteralPath $_ -PathType Leaf} | Select-Object -First 1
if($rm -and (Get-Process -Name Rainmeter -ErrorAction SilentlyContinue)){& $rm '!RefreshApp' | Out-Null}
Write-Host '[OK] V3 revertida. Reinicia Zebar desde la bandeja para recuperar el tema anterior.' -ForegroundColor Green

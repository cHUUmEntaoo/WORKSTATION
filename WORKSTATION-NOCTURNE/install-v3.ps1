# WORKSTATION NOCTURNE - COMMAND DECK V3
# No admin required. Does not install software, touch Docker/WSL/SSH or replace personal hotkeys.
# Installs Zebar and Rainmeter visual modules; changes only GlazeWM top and left gap.
[CmdletBinding()]
param([switch]$NoRestart, [switch]$SkipGlazeWM, [switch]$NoDashboard)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$source = Join-Path $root 'theme'
$liveZ = Join-Path $HOME '.glzr\zebar\workstation-bar'
$liveR = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins\WORKSTATION'
$glaze = Join-Path $HOME '.glzr\glazewm\config.yaml'
$repo = Join-Path $HOME 'Projects\WORKSTATION'
$public = Join-Path $repo 'WORKSTATION-NOCTURNE'
$hasRepo = (Test-Path -LiteralPath (Join-Path $repo '.git')) -and (Test-Path -LiteralPath $public)
$backup = Join-Path $HOME ('.config\workstation\backups\command-deck-v3-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$manifestPath = Join-Path $backup 'manifest.json'
$utf8 = [System.Text.UTF8Encoding]::new($false)
$changes = [System.Collections.ArrayList]::new()
$rainmeter = @(
  (Join-Path $env:ProgramFiles 'Rainmeter\Rainmeter.exe'),
  (Join-Path $env:LOCALAPPDATA 'Programs\Rainmeter\Rainmeter.exe')
) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1

if (-not $rainmeter) { throw 'Rainmeter.exe no encontrado; instala Rainmeter primero. No se modifico nada.' }
if (-not (Test-Path -LiteralPath $liveZ -PathType Container)) { throw "Falta WORKSTATION-BAR: $liveZ. Abre Zebar una vez antes de instalar." }
if (-not (Test-Path -LiteralPath (Join-Path $source 'zebar\zpack.json'))) { throw 'ZIP incompleto: falta zpack.json.' }
if (-not (Test-Path -LiteralPath (Join-Path $source 'rainmeter\WORKSTATION\Dock\Dock.ini'))) { throw 'ZIP incompleto: falta Dock.ini.' }
if (-not $SkipGlazeWM -and -not (Test-Path -LiteralPath $glaze)) { throw 'config.yaml de GlazeWM no encontrado.' }
Get-Content -LiteralPath (Join-Path $source 'zebar\zpack.json') -Raw | ConvertFrom-Json | Out-Null

# Validate original gap format BEFORE copying anything. No global YAML regex replacement.
$glazeOriginal = $null
$glazeUpdated = $null
if (-not $SkipGlazeWM) {
  $glazeOriginal = [System.IO.File]::ReadAllText($glaze)
  $m = [regex]::Match($glazeOriginal,'(?ms)^gaps:[ \t]*\r?\n.*?(?=^[A-Za-z][A-Za-z0-9_-]*:[ \t]*(?:\r?\n|$)|\z)')
  if (-not $m.Success) { throw 'Seccion gaps: no reconocida. GlazeWM no se modifico.' }
  $section = $m.Value
  if ([regex]::Matches($section,'(?m)^[ \t]+top[ \t]*:').Count -ne 1 -or
      [regex]::Matches($section,'(?m)^[ \t]+left[ \t]*:').Count -ne 1) {
    throw 'gaps.outer_gap.top / left no encontrados exactamente una vez.'
  }
  $section = [regex]::Replace($section,'(?m)^(?<indent>[ \t]+)top[ \t]*:[^\r\n]*$', '${indent}top: ''50px''')
  $section = [regex]::Replace($section,'(?m)^(?<indent>[ \t]+)left[ \t]*:[^\r\n]*$', '${indent}left: ''60px''')
  $glazeUpdated = $glazeOriginal.Substring(0,$m.Index) + $section + $glazeOriginal.Substring($m.Index + $m.Length)
}

function Save-Target([string]$target, [string]$name) {
  $exists = Test-Path -LiteralPath $target -PathType Leaf
  $saved = Join-Path $backup $name
  if ($exists) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $saved) | Out-Null
    Copy-Item -LiteralPath $target -Destination $saved -Force
  }
  [void]$changes.Add([pscustomobject]@{Target=$target;Backup=$saved;Existed=[bool]$exists})
  Write-Manifest
}
function Write-Manifest {
  ConvertTo-Json -InputObject @($changes.ToArray()) -Depth 4 |
    Set-Content -LiteralPath $manifestPath -Encoding utf8
}
function Put-File([string]$from,[string]$to,[string]$name) {
  if (-not (Test-Path -LiteralPath $from -PathType Leaf)) { throw "Falta origen: $from" }
  Save-Target $to $name
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $to) | Out-Null
  Copy-Item -LiteralPath $from -Destination $to -Force
}
function Patch-Rainmeter([string]$text,[string]$key,[string]$value) {
  $m = [regex]::Match($text,'(?ms)^\[Rainmeter\][ \t]*\r?\n.*?(?=^\[[^\]]+\]|\z)')
  if (-not $m.Success) { throw 'No existe [Rainmeter] en el panel heredado.' }
  $section = $m.Value
  $opt = '(?m)^' + [regex]::Escape($key) + '[ \t]*=[^\r\n]*$'
  if ([regex]::IsMatch($section,$opt)) {
    $section = [regex]::Replace($section,$opt,[System.Text.RegularExpressions.MatchEvaluator]{param($m) $key+'='+$value})
  } else {
    $section = $section.TrimEnd("`r","`n") + "`n" + $key+'='+$value+"`n"
  }
  return $text.Substring(0,$m.Index)+$section+$text.Substring($m.Index+$m.Length)
}
function Restore-Tracked {
  for ($idx = $changes.Count - 1; $idx -ge 0; $idx--) {
    $item = $changes[$idx]
    try {
      if ($item.Existed) { Copy-Item -LiteralPath $item.Backup -Destination $item.Target -Force }
      elseif (Test-Path -LiteralPath $item.Target) { Remove-Item -LiteralPath $item.Target -Force }
    } catch { Write-Warning "Rollback: $($item.Target): $($_.Exception.Message)" }
  }
}
function Reload-Wm {
  if (-not (Get-Process -Name glazewm -ErrorAction SilentlyContinue)) { return }
  $result = (& glazewm command wm-reload-config 2>&1 | Out-String)
  if ($LASTEXITCODE -ne 0 -or $result -notmatch '"success"\s*:\s*true') {
    throw "GlazeWM rechazo config.yaml: $result"
  }
}
function Restart-Zebar {
  $running = @(Get-Process -Name zebar -ErrorAction SilentlyContinue)
  $exe = $running | Where-Object { $_.Path -and (Test-Path -LiteralPath $_.Path) } | Select-Object -First 1 -ExpandProperty Path
  if (-not $exe) {
    $command = Get-Command zebar -ErrorAction SilentlyContinue
    if ($command) { $exe = $command.Source }
  }
  if ($running.Count -gt 0) { $running | Stop-Process -Force }
  Start-Sleep -Milliseconds 700
  if ($exe) { Start-Process -FilePath $exe | Out-Null }
  else { Write-Warning 'Reinicia Zebar desde su acceso directo o menu de bandeja.' }
}

New-Item -ItemType Directory -Force -Path $backup | Out-Null
Write-Manifest
Write-Host '[1/5] Backup y validacion previa...' -ForegroundColor Cyan
try {
  foreach ($name in @('with-glazewm.html','styles.css','zpack.json')) {
    $from = Join-Path $source ('zebar\'+$name)
    Put-File $from (Join-Path $liveZ $name) ('live-zebar\'+$name)
    if ($hasRepo) { Put-File $from (Join-Path $public ('theme\zebar\'+$name)) ('repo-zebar\'+$name) }
  }
  Write-Host '[2/5] Dock, Home, Activity, Launcher y scripts...' -ForegroundColor Cyan
  $rainSrc = Join-Path $source 'rainmeter\WORKSTATION'
  # Operations / ControlCenter are preserved if already installed.
  $overwrite = @('Dock','Home','Activity','Launcher','@Resources')
  foreach ($dir in $overwrite) {
    Get-ChildItem -LiteralPath (Join-Path $rainSrc $dir) -File -Recurse | ForEach-Object {
      $relative = $_.FullName.Substring($rainSrc.Length).TrimStart('\','/')
      Put-File $_.FullName (Join-Path $liveR $relative) ('live-rainmeter\'+$relative)
      if ($hasRepo) { Put-File $_.FullName (Join-Path $public ('theme\rainmeter\WORKSTATION\'+$relative)) ('repo-rainmeter\'+$relative) }
    }
  }
  # Trust only our local helper scripts, without relaxing Windows execution policy.
  Get-ChildItem -LiteralPath (Join-Path $liveR '@Resources\Scripts') -Filter '*.ps1' -File -ErrorAction SilentlyContinue |
    Unblock-File -ErrorAction SilentlyContinue
  # Patch event handlers only; never replace user's functional calendar/audio modules.
  foreach ($module in @('Operations','ControlCenter')) {
    $meter = if ($module -eq 'Operations') {'OperationsIndicator'} else {'ControlCenterIndicator'}
    $file = "$module\$module.ini"
    $locations = @((Join-Path $liveR $file))
    if ($hasRepo) { $locations += (Join-Path $public ('theme\rainmeter\WORKSTATION\'+$file)) }
    foreach ($location in $locations) {
      if (-not (Test-Path -LiteralPath $location -PathType Leaf)) {
        $fallback = Join-Path $rainSrc $file
        Put-File $fallback $location ('fallback-'+$module+'-'+[IO.Path]::GetFileName((Split-Path -Parent $location))+'\'+$file)
      }
      $old = [System.IO.File]::ReadAllText($location)
      $updated = Patch-Rainmeter $old 'OnRefreshAction' ('[!ShowMeter "'+$meter+'" "WORKSTATION\Dock"][!Redraw "WORKSTATION\Dock"]')
      $updated = Patch-Rainmeter $updated 'OnCloseAction' ('[!HideMeter "'+$meter+'" "WORKSTATION\Dock"][!Redraw "WORKSTATION\Dock"]')
      if ($updated -ne $old) {
        Save-Target $location ('patch-'+$module+'-'+[guid]::NewGuid().ToString('N')+'.ini')
        [IO.File]::WriteAllText($location,$updated,$utf8)
      }
    }
  }
  Write-Host '[3/5] GlazeWM: top 50px, left 60px (sin tocar hotkeys)...' -ForegroundColor Cyan
  if (-not $SkipGlazeWM -and $glazeUpdated -ne $glazeOriginal) {
    Save-Target $glaze 'glazewm\config.yaml'
    [IO.File]::WriteAllText($glaze,$glazeUpdated,$utf8)
    Reload-Wm
  }
  if ($hasRepo) {
    foreach($file in @('install-v3.ps1','restore-v3.ps1','check-v3.ps1','publish-v3.ps1','README-V3.md')) {
      Put-File (Join-Path $root $file) (Join-Path $public $file) ('repo-scripts\'+$file)
    }
  }
  if ($hasRepo) {
    $notes = @'

## NOCTURNE COMMAND DECK V3

Barra Zebar de 48px con ventanas reales de GlazeWM, indicadores de sistema,
media controls, dock lateral de 60px, Home, Activity y Launcher con datos
reales de Windows. Instala las dependencias, despues ejecuta:
`./WORKSTATION-NOCTURNE/install-v3.ps1`. Documentacion:
`WORKSTATION-NOCTURNE/README-V3.md`. Backups y restauracion incluidos.
'@
    foreach($doc in @((Join-Path $repo 'README.md'),(Join-Path $public 'README.md'))) {
      if (Test-Path -LiteralPath $doc -PathType Leaf) {
        $original = [IO.File]::ReadAllText($doc)
        if (-not $original.Contains('NOCTURNE COMMAND DECK V3')) {
          Save-Target $doc ('repo-docs\'+[IO.Path]::GetFileName((Split-Path -Parent $doc))+'-'+[guid]::NewGuid().ToString('N')+'.md')
          [IO.File]::WriteAllText($doc,($original+"`n"+$notes),$utf8)
        }
      }
    }
  }
  Write-Host '[4/5] Activando la interfaz real...' -ForegroundColor Cyan
  if (-not $NoRestart) {
    if (-not (Get-Process -Name Rainmeter -ErrorAction SilentlyContinue)) { Start-Process -FilePath $rainmeter; Start-Sleep -Seconds 2 }
    & $rainmeter '!RefreshApp' | Out-Null
    Start-Sleep -Milliseconds 700
    foreach($mod in @('Home','Activity','Launcher','Operations','ControlCenter')) {
      & $rainmeter '!DeactivateConfig' "WORKSTATION\$mod" | Out-Null
    }
    & $rainmeter '!ActivateConfig' 'WORKSTATION\Dock' 'Dock.ini' | Out-Null
    Start-Sleep -Milliseconds 300
    & $rainmeter '!Move' '0' '52' 'WORKSTATION\Dock' | Out-Null
    & $rainmeter '!ZPos' '-2' 'WORKSTATION\Dock' | Out-Null
    if (-not $NoDashboard) {
      foreach($mod in @('Home','Activity')) {
        & $rainmeter '!ActivateConfig' "WORKSTATION\$mod" "$mod.ini" | Out-Null
        Start-Sleep -Milliseconds 180
        $x = if ($mod -eq 'Home') {'64'} else {'500'}
        & $rainmeter '!Move' $x '53' "WORKSTATION\$mod" | Out-Null
        & $rainmeter '!ZPos' '-2' "WORKSTATION\$mod" | Out-Null
      }
    }
    Restart-Zebar
  }
  Write-Host '[5/5] Verificacion final...' -ForegroundColor Cyan
  foreach($path in @((Join-Path $liveZ 'with-glazewm.html'), (Join-Path $liveZ 'zpack.json'), (Join-Path $liveR 'Dock\Dock.ini'), (Join-Path $liveR 'Home\Home.ini'), (Join-Path $liveR 'Activity\Activity.ini'))) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Falta archivo: $path" }
  }
  $last = Join-Path $HOME '.config\workstation\command-deck-v3-last.txt'
  Set-Content -LiteralPath $last -Value $backup -Encoding utf8
  Write-Host '[OK] NOCTURNE COMMAND DECK V3 instalado.' -ForegroundColor Green
  Write-Host '[OK] Barra Zebar: 48px. GlazeWM: top 50px; dock reservado 60px.' -ForegroundColor Green
  Write-Host '[OK] Home / Activity reales, con controles de Windows.' -ForegroundColor Green
  Write-Host '[INFO] Los paneles de inicio estan en el escritorio; Firefox los cubrira al trabajar.'
  Write-Host "[BACKUP] $backup" -ForegroundColor Yellow
  if($hasRepo) { Write-Host '[GIT] Archivos preparados localmente, SIN publicar automaticamente.' -ForegroundColor Cyan }
  Write-Host 'COMMAND DECK V3: COMPLETE' -ForegroundColor Green
} catch {
  $err = $_.Exception.Message
  Write-Warning "Fallo de instalacion: $err"
  Write-Warning 'Revirtiendo los archivos modificados...'
  Restore-Tracked
  try { Reload-Wm } catch { Write-Warning "GlazeWM rollback: $($_.Exception.Message)" }
  throw "Instalacion cancelada y rollback solicitado. $err"
}

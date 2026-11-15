# Publish only the reviewed NOCTURNE project tree. Never stages SSH keys or unrelated work.
[CmdletBinding()]
param([switch]$Push)
$ErrorActionPreference='Stop'
$repo=Join-Path $HOME 'Projects\WORKSTATION'
if(-not(Test-Path -LiteralPath (Join-Path $repo '.git'))){throw "Repositorio no encontrado: $repo"}
Push-Location $repo
try{
  git add -- README.md WORKSTATION-NOCTURNE/README.md WORKSTATION-NOCTURNE/theme/zebar WORKSTATION-NOCTURNE/theme/rainmeter/WORKSTATION WORKSTATION-NOCTURNE/install-v3.ps1 WORKSTATION-NOCTURNE/restore-v3.ps1 WORKSTATION-NOCTURNE/check-v3.ps1 WORKSTATION-NOCTURNE/publish-v3.ps1 WORKSTATION-NOCTURNE/README-V3.md
  if($LASTEXITCODE -ne 0){throw 'git add fallo.'}
  git diff --cached --check
  if($LASTEXITCODE -ne 0){throw 'git diff --cached --check encontro problemas.'}
  git diff --cached --stat
  git status -sb
  if(-not $Push){
    Write-Host 'Listo para revision. Para publicar: .\WORKSTATION-NOCTURNE\publish-v3.ps1 -Push' -ForegroundColor Cyan
    return
  }
  $answer=Read-Host 'Escribe PUBLISH para confirmar commit y push'
  if($answer -cne 'PUBLISH'){Write-Host 'Cancelado; staged files preserved.';return}
  git diff --cached --quiet
  if($LASTEXITCODE -eq 0){Write-Host 'No hay cambios por publicar.';return}
  git commit -m 'feat: NOCTURNE Command Deck V3 status bar and dashboard'
  if($LASTEXITCODE -ne 0){throw 'Commit fallo; push cancelado.'}
  git push origin main
  if($LASTEXITCODE -ne 0){throw 'Push fallo; commit local conservado.'}
  git status -sb
  Write-Host '[SUCCESS] NOCTURNE V3 publicado.' -ForegroundColor Green
} finally {Pop-Location}

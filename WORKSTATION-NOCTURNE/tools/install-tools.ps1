# Optional, separate from the visual theme. Installs selected dev tools through winget.
[CmdletBinding()]
param([switch]$Dev,[switch]$All)
if (-not $Dev -and -not $All) {Write-Host 'Use -Dev or -All. No packages installed.';exit 0}
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {throw 'winget not found'}
$ids=@('Git.Git','Microsoft.VisualStudioCode','Microsoft.WindowsTerminal','Microsoft.PowerShell','OpenJS.NodeJS.LTS','Python.Python.3.13')
foreach($id in $ids) {
  & winget install --exact --id $id --accept-package-agreements --accept-source-agreements
  if($LASTEXITCODE -ne 0) {Write-Warning "Review $id installation (exit $LASTEXITCODE)"}
}
Write-Host 'Optional dev tools process completed. Open a new terminal to refresh PATH.'

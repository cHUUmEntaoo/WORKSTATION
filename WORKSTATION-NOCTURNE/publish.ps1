# WORKSTATION NOCTURNE - publishing helper
# Run from an extracted WORKSTATION-NOCTURNE folder inside your Git repository.
[CmdletBinding()]
param([switch]$Push)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$repo=Split-Path -Parent $root
$gitRoot=(& git -C $repo rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0) { throw 'The parent directory must be a Git repository.' }
$resolved=[IO.Path]::GetFullPath($gitRoot).TrimEnd('\','/')
$expected=[IO.Path]::GetFullPath($repo).TrimEnd('\','/')
if ($resolved -ine $expected) { throw "Unexpected repository root: $gitRoot" }
$current=( & git -C $repo branch --show-current).Trim()
if ($current -ne 'main') { throw "Expected branch main; found '$current'." }
$existing=Join-Path $repo 'README.md'
$incoming=Join-Path $root 'README.md'
if (Test-Path -LiteralPath $existing) {
    $backup=Join-Path $env:USERPROFILE ('.config\workstation\backups\README-before-nocturne-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.md')
    New-Item -ItemType Directory -Path (Split-Path -Parent $backup) -Force | Out-Null
    Copy-Item -LiteralPath $existing -Destination $backup -Force
    Write-Host "Existing README backed up locally: $backup"
}
Copy-Item -LiteralPath $incoming -Destination $existing -Force
& git -C $repo add -- README.md WORKSTATION-NOCTURNE
if ($LASTEXITCODE -ne 0) {throw 'git add failed'}
& git -C $repo diff --cached --check
if ($LASTEXITCODE -ne 0) {throw 'Staged validation failed; not publishing'}
& git -C $repo diff --cached --stat
& git -C $repo status -sb
if (-not $Push) {
    Write-Host 'Staged only. Review files, then re-run .\WORKSTATION-NOCTURNE\publish.ps1 -Push'
    exit 0
}
Write-Host 'The command will commit staged changes and push to origin/main.'
$ok=Read-Host 'Type PUBLISH to authorize git commit + git push'
if ($ok -cne 'PUBLISH') {Write-Host 'Cancelled. Staged files remain in Git.';exit 0}
& git -C $repo commit -m 'feat: publish WORKSTATION NOCTURNE interactive desktop'
if ($LASTEXITCODE -ne 0) {throw 'git commit failed'}
& git -C $repo push origin main
if ($LASTEXITCODE -ne 0) {throw 'git push failed'}
& git -C $repo status -sb
Write-Host '[SUCCESS] Published to GitHub.'

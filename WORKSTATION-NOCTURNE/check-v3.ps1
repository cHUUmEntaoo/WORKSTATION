# Read-only WORKSTATION NOCTURNE V3 health check
$z=Join-Path $HOME '.glzr\zebar\workstation-bar'
$r=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins\WORKSTATION'
$g=Join-Path $HOME '.glzr\glazewm\config.yaml'
$paths=@{
 'Zebar HTML'=(Join-Path $z 'with-glazewm.html')
 'Zebar theme'=(Join-Path $z 'styles.css')
 'Zebar pack'=(Join-Path $z 'zpack.json')
 'Rainmeter dock'=(Join-Path $r 'Dock\Dock.ini')
 'Rainmeter Home'=(Join-Path $r 'Home\Home.ini')
 'Rainmeter Activity'=(Join-Path $r 'Activity\Activity.ini')
 'Rainmeter launcher'=(Join-Path $r 'Launcher\Launcher.ini')
 'GlazeWM'=$g
}
foreach($key in ($paths.Keys | Sort-Object)){
  $path=$paths[$key]
  if(Test-Path -LiteralPath $path -PathType Leaf){Write-Host "[OK] $key" -ForegroundColor Green}
  else{Write-Host "[MISSING] $key ($path)" -ForegroundColor Yellow}
}
foreach($process in @('glazewm','zebar','Rainmeter')){
  if(Get-Process -Name $process -ErrorAction SilentlyContinue){Write-Host "[RUNNING] $process" -ForegroundColor Green}
  else {Write-Host "[STOPPED] $process" -ForegroundColor Yellow}
}
if(Test-Path -LiteralPath $g){
  Select-String -Path $g -Pattern "^[ \t]+(top|left):[ \t]*'?(50|60)px" | Select-Object -First 5
}

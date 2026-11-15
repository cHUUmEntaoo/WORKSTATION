# Read-only health check. It never starts services or changes settings.
$ErrorActionPreference='Stop'
$paths=@{
  'Zebar HTML' = "$HOME\.glzr\zebar\workstation-bar\with-glazewm.html"
  'Zebar CSS' = "$HOME\.glzr\zebar\workstation-bar\styles.css"
  'Rainmeter Dock' = "$([Environment]::GetFolderPath('MyDocuments'))\Rainmeter\Skins\WORKSTATION\Dock\Dock.ini"
  'Rainmeter Operations' = "$([Environment]::GetFolderPath('MyDocuments'))\Rainmeter\Skins\WORKSTATION\Operations\Operations.ini"
  'Rainmeter Control' = "$([Environment]::GetFolderPath('MyDocuments'))\Rainmeter\Skins\WORKSTATION\ControlCenter\ControlCenter.ini"
  'Rainmeter Calendar' = "$([Environment]::GetFolderPath('MyDocuments'))\Rainmeter\Skins\WORKSTATION\ControlCenter\Calendar.lua"
  'Rainmeter Launcher' = "$([Environment]::GetFolderPath('MyDocuments'))\Rainmeter\Skins\WORKSTATION\Launcher\Launcher.ini"
  'GlazeWM YAML' = "$HOME\.glzr\glazewm\config.yaml"
}
foreach($entry in $paths.GetEnumerator() | Sort-Object Name) {
  '{0,-26} {1,-8} {2}' -f $entry.Key, $(if(Test-Path $entry.Value){'OK'}else{'MISSING'}), $entry.Value
}
foreach($app in @('glazewm','zebar','Rainmeter','wt')) {
  $command=Get-Command $app -ErrorAction SilentlyContinue
  '{0,-26} {1}' -f $app, $(if($command){'IN PATH'}else{'Check installation / PATH'})
}

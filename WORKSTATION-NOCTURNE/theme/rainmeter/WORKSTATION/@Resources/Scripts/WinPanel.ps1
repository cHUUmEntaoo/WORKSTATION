param([Parameter(Mandatory=$true)][ValidateSet('Search','Notifications','QuickSettings')][string]$Panel)
$ErrorActionPreference='Stop'
$keys=@{ Search=0x53; Notifications=0x4E; QuickSettings=0x41 }
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class WorkstationKeySender {
 [DllImport("user32.dll")] private static extern void keybd_event(byte vk,byte scan,uint flags,UIntPtr extra);
 public static void Press(byte key) {
  keybd_event(0x5B,0,0,UIntPtr.Zero);
  keybd_event(key,0,0,UIntPtr.Zero);
  keybd_event(key,0,2,UIntPtr.Zero);
  keybd_event(0x5B,0,2,UIntPtr.Zero);
 }
}
'@
[WorkstationKeySender]::Press([byte]$keys[$Panel])

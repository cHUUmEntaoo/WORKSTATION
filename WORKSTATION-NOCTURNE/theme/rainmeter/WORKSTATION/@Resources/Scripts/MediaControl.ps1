# WORKSTATION NOCTURNE - Windows media key control (no admin)
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('Prev','PlayPause','Next')]
  [string]$Action
)
$ErrorActionPreference='Stop'
$virtualKeys = @{ Prev=0xB1; PlayPause=0xB3; Next=0xB0 }
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class NocturneMediaKeys {
  [DllImport("user32.dll")]
  private static extern void keybd_event(byte key, byte scan, uint flags, UIntPtr extra);
  public static void Press(byte key) {
    keybd_event(key,0,0,UIntPtr.Zero);
    keybd_event(key,0,2,UIntPtr.Zero);
  }
}
'@
[NocturneMediaKeys]::Press([byte]$virtualKeys[$Action])

# WORKSTATION ULTIMATE — NOCTURNE COMMAND DECK V3

**Windows 11 · GlazeWM · Zebar · Rainmeter · Red Team workstation**

Designed from the user's NOCTURNE mockup as **real Windows desktop UI**, not a screenshot skin.

## Key features

- **48-px Zebar command bar:** branded status, five quick workspaces, actual GlazeWM running windows, focused task controls, real CPU and RAM usage, network/interface and traffic tooltip, battery, weather when the provider returns it, date/time, audio status and a media play/pause button when a media session exists.
- **60-px desktop rail:** 11 interactive items for overview, Home, Activity, launcher, Operations, Control Center, Terminal, VS Code, Explorer, Notifications and Settings. Real CPU/RAM/network/time in the footer. Rainmeter rail lives on the desktop layer (`-2`).
- **Home (430 px):** live Windows clock, navigable Lua calendar, real CPU/RAM/disk/network, shortcuts to Windows settings and media hardware-key controls.
- **Activity (386 px):** actual Windows Notification Center (Win+N), Quick Settings (Win+A), Search (Win+S), Windows volume and app shortcuts. Private Windows notifications are **not** read or fabricated.
- **Launcher:** Windows Search, terminal, Debian WSL, VS Code, Firefox, Explorer, installed applications, Task Manager and Windows Settings.
- **Overview:** loads Home and Activity side-by-side **on the desktop layer**; when an application opens, it covers the panels. Clicking their rail buttons raises them temporarily for interaction.

This uses native Windows functions; no custom notification database, unsupported Wi-Fi toggling, fictional security scans, pretend VPN status, or fake GPU readings.

## Prerequisites

Windows 11, GlazeWM 3, Zebar 3-compatible `WORKSTATION-BAR`, Rainmeter 4.5. Windows Terminal, Debian WSL, VS Code and Firefox are optional shortcuts and must be installed separately. The existing bar loads React and Zebar from online CDN sources; Internet access may be required on first launch.

## One-command update of an existing WORKSTATION

Extract this ZIP, open **PowerShell 7 (not elevated)** in the extracted folder, then:

```powershell
.\install-v3.ps1
```

It backs up and installs the live theme, updates *only* `gaps.outer_gap.top` to `50px` and `left` to `60px` in the existing GlazeWM YAML, requests a GlazeWM reload with error checking, reloads Rainmeter and restarts Zebar. Your keyboard shortcuts, Docker, WSL, SSH, Git credentials and wallpaper are preserved. It does **not** automatically push to GitHub.

Use `-SkipGlazeWM` if you already manually provide 50-px/60-px offsets, or `-NoDashboard` if you prefer only the dock initially.

## Public GitHub install

When this package is added under `WORKSTATION-NOCTURNE/` in the repo, a fresh user can install the prerequisites, then run:

```powershell
.\WORKSTATION-NOCTURNE\install-v3.ps1
```

First run the existing `install.ps1` from the repository to initialize the WORKSTATION-BAR pack if it has not been configured yet. Select the pack in Zebar's settings on a new PC; the V3 installer requires that directory to exist. GlazeWM is not downloaded or installed automatically here.

## Test

Click **Overview** (first dock icon) to show Home + Activity on the wallpaper, then click VS Code or Firefox. The app should appear *over* the dashboard, never underneath the dock, while the top bar remains visible. The rail stays inside the reserved 60-px gutter. Click Home or Activity to bring a panel to the front for interacting, close it with X to hide it. Use the `-NoDashboard` option for an empty desktop launch. Media keys control the current Windows media session if available.

**The on-disk files can be structurally validated, but a final visual and interaction test must be done on a real Windows 11 desktop.** Scaling depends on DPI and monitor size; the two default desktop panels fit best on screens 900 px high or taller.

## Restore

```powershell
.\restore-v3.ps1
```

Type `RESTORE` when asked. All files that V3 touched are tracked in a timestamped backup under `%USERPROFILE%\.config\workstation\backups`. You may need to reload Zebar from its tray menu after restoration.

## GitHub publication

If you installed V3 inside the owner's repo, the script syncs its *non-sensitive theme files* into `WORKSTATION-NOCTURNE` but does not publish. Inspect and publish with:

```powershell
.\publish-v3.ps1
.\publish-v3.ps1 -Push
```

The second invocation requests typing `PUBLISH` before committing or pushing. Do not publish private paths, keys, personal files, or screenshot metadata.

## Architecture

- GlazeWM: window layouts, user hotkeys, reserved top and left gutters.
- Zebar: real-time bar and active window/task navigation using supported providers.
- Rainmeter: dashboard and interactive desktop rail with real Windows measurements.
- PowerShell: native notification/search/media keyboard actions and idempotent installation/rollback.

Third-party apps retain their own licenses. The custom scripts and interface are made available under the project's license.

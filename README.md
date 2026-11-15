# WORKSTATION ULTIMATE — NOCTURNE

> Windows 11 desktop customization: **GlazeWM + Zebar + Rainmeter**, a compact dark Red Team dock and interactive desktop widgets.

![WORKSTATION NOCTURNE](theme/wallpaper/nocturne-original.png)

## What you get

- **GlazeWM** tiling window manager and nine organized workspaces (with optional `-ApplyGlazeWM`).
- **Zebar** custom Catppuccin-style top bar with workspaces, network, CPU, RAM, battery and weather.
- **Rainmeter** compact dock + expandable **Operations**, **Control Center** (live calendar and system volume), and **Launcher** (app and native Windows shortcuts).
- Optional original **red/navy wallpaper**. Its artwork is freely included with the repository; no third-party wallpapers are redistributed.
- Installer, health check, backups and restore. No WSL, Docker or SSH configuration is changed.

## RC1 hotfix (2026-11-15)

Fixed Rainmeter CLI invocation in `install.ps1`: bangs and their parameters are now passed as separate arguments. The previous archive could cause an erroneous `C:\Program Files\Rainmeter\DeactivateConfig\...\Rainmeter.ini` permissions warning. If you used that installer, close Rainmeter from its tray icon, use this corrected package and restart normally. **Do not change permissions of Program Files or run Rainmeter elevated.**

## Install in a few clicks (Windows 11)

1. **Install prerequisites**: [GlazeWM](https://github.com/glzr-io/glazewm) (select **Zebar** in its installer), [Rainmeter](https://www.rainmeter.net/) and [Windows Terminal](https://github.com/microsoft/terminal). Or use the optional `-InstallApps` flag below, which also requests the Zebar package.
2. Click **Code → Download ZIP** on this repository, unzip it, open the `WORKSTATION-NOCTURNE` folder, then open **PowerShell** in that folder.
3. Run:

   ```powershell
   .\install.ps1 -SetWallpaper
   ```

   If your machine has no dependencies, run `winget install --id glzr-io.glazewm -e` and `winget install --id glzr-io.zebar -e` and `winget install --id Rainmeter.Rainmeter -e`, then launch their applications. Optional `-InstallApps` automates package installation requests, but Zebar's installer checkbox may require interaction.
4. In **Zebar**, choose pack **WORKSTATION-BAR** with widget `with-glazewm` and reload configs. Launch GlazeWM. Run Rainmeter or open **Manage → WORKSTATION → Dock → Dock.ini → Load**.
5. Click the left dock buttons. The first shows **Operations**, the second opens **Launcher**, and **CC** shows the **Control Center**.

**Existing GlazeWM users:** The installer does **not overwrite your GlazeWM configuration by default**, so your hotkeys/workspaces remain intact. To use this repository's nine-workspace template on a new machine, explicitly run:

```powershell
.\install.ps1 -ApplyGlazeWM -SetWallpaper
```

The installer backs up replaced files first. The optional `-ApplyGlazeWM` flag **replaces existing GlazeWM hotkeys**: review the YAML before applying it. It can be used for a new machine, but avoid it on your daily workstation unless intended.

### If PowerShell blocks local scripts

Inspect `install.ps1` first. Windows may mark files downloaded from the internet; after reviewing, use `Unblock-File .\install.ps1` or your permitted execution policy. **Do not disable security protections system-wide.**

## Update your personal setup before publishing

If this is your own WORKSTATION and you have already hand-tuned Rainmeter/Zebar, run:

```powershell
.\export-current.ps1
```

This copies your current working **Zebar and Rainmeter** files into `theme/`, except the Dock: the bundled Dock intentionally adds the new Launcher action. To export your old Dock instead, opt in with `-IncludeDock` and review its app button mapping. To include your exact keyboard shortcuts as well, use `-IncludeGlazeWM`, inspect the exported YAML for private paths, and only then commit. The package's included GlazeWM template is from an earlier tested configuration and may not include all your latest hotkeys until exported.

Review before publishing:

```powershell
git diff --check
git status -sb
git diff --stat
```

## Recovery

Every install creates a backup under `%USERPROFILE%\.config\workstation\backups\nocturne-TIMESTAMP` with a manifest. Restore the most recent install with:

```powershell
.\restore.ps1
```

The restore script asks you to type `RESTORE`. It reverses only installed files. It does not automatically revert the Windows wallpaper; see `previous-wallpaper-path.txt` in the backup directory if you changed it.

## Verify

```powershell
.\check.ps1
```

## Optional development tools

The interface is deliberately separate from development and security tooling. To install a curated baseline when desired:

```powershell
.\tools\install-tools.ps1 -Dev
```

This is optional, may prompt for installation, and does not install Kali/Parrot or pentesting packages. WSL and Docker remain personal choices.

## Important limitations

- Native Windows notification history and quick settings use **Windows-native panels**, not a copied notification database. Native panel shortcuts are launched via a small PowerShell helper and must be validated on each machine.
- Launcher is a **shortcut dashboard**, not yet a custom full-text search engine. The search button opens Windows Search.
- GlazeWM/Zebar versions and user settings may differ; the installer cannot guarantee identical behavior on all displays, DPI settings or Windows builds.
- Background skins are not a replacement for Windows's taskbar or security UI. The taskbar may be auto-hidden using Windows settings.
- This repository does not include licensed third-party wallpapers or private credentials.

## Architecture

```text
Windows 11
  ├── GlazeWM                   window layout / keyboard shortcuts
  ├── Zebar WORKSTATION-BAR      top metrics / workspaces
  └── Rainmeter WORKSTATION
        ├── Dock                icon navigation
        ├── Operations          real CPU/RAM/network/disk
        ├── ControlCenter       calendar, master volume, settings
        └── Launcher            application and native Windows shortcuts
```

## Credits and licenses

This repository bundles custom configuration files and a procedurally created wallpaper. [GlazeWM](https://github.com/glzr-io/glazewm), [Zebar](https://github.com/glzr-io/zebar), and [Rainmeter](https://www.rainmeter.net/) are separate third-party projects, with their own licenses and distribution terms. Not affiliated with them.

The supplied configuration/scripts are made available under the [MIT License](LICENSE). The upstream dependencies retain their own licenses. Feel free to fork and adapt, and report problems through GitHub Issues.

## NOCTURNE INTERACTIVE V2

The updated Rainmeter dock includes Home, Launcher, Activity, Operations
and Control Center. The 60px desktop dock and existing GlazeWM shortcuts
are preserved. After downloading/cloning this repository and installing
GlazeWM, Zebar and Rainmeter, run
`./WORKSTATION-NOCTURNE/install.ps1 -SetWallpaper` in PowerShell
from the repository root. The public installer recursively installs the
new Rainmeter modules. Test the new Home / Activity buttons and read
`WORKSTATION-NOCTURNE/README.md` for limitations and rollback details.

## NOCTURNE COMMAND DECK V3

Barra Zebar de 48px con ventanas reales de GlazeWM, indicadores de sistema,
media controls, dock lateral de 60px, Home, Activity y Launcher con datos
reales de Windows. Instala las dependencias, despues ejecuta:
`./WORKSTATION-NOCTURNE/install-v3.ps1`. Documentacion:
`WORKSTATION-NOCTURNE/README-V3.md`. Backups y restauracion incluidos.
## NOCTURNE V3.1

The current Command Deck, Red Team status bar and
interactive desktop are documented in
[WORKSTATION-NOCTURNE/README-V3.1.md](WORKSTATION-NOCTURNE/README-V3.1.md).
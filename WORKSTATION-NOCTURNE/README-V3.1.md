# WORKSTATION NOCTURNE V3.1

## Tested configuration

Windows 11, PowerShell 7, GlazeWM, Zebar and Rainmeter.

### Status bar

- WORKSTATION NOCTURNE branding
- RED TEAM identity
- GlazeWM workspace navigation
- Active window title
- Network connection
- CPU and RAM metrics
- Battery information
- Weather when available
- Date and time

The working Zebar package contains the required file access
metadata. Use the supplied zpack.json, HTML and CSS together.

### Desktop

- Rainmeter interactive dock
- Home, Activity and Launcher
- Operations and Control Center
- Desktop wallpaper
- GlazeWM tiled windows

The reference workstation reserves 50px at the top and
60px on the left. These margins depend on the display setup.

### Installation

Install GlazeWM, Zebar and Rainmeter first.

Run install.ps1 from the WORKSTATION-NOCTURNE folder.
Review optional flags before replacing GlazeWM settings.

Select the WORKSTATION-BAR widget in Zebar settings.

Existing users must ensure the installed zpack.json matches
theme/zebar/zpack.json. The base installer preserves an
existing widget-pack metadata file.

### Troubleshooting

If the Zebar widget shows a 404 error, verify the
zpack.json file access configuration and reload Zebar.

To launch Zebar independently of PowerShell:

    glazewm command shell-exec zebar

Do not launch Zebar in a terminal session that must remain
open for the bar to survive.

If the dock disappears, open Rainmeter Manage and load
WORKSTATION/Dock/Dock.ini.

### Important limitations

System metrics use real providers.

Native notifications remain managed by Windows.
No fabricated security scan results or VPN states are shown.

The design has been tested on the owner's Windows workstation.
A clean installation on another computer is still required
before declaring a universal stable release.

### Version history

- RC1: initial public desktop
- V2: interactive navigation
- V3: Command Deck
- V3.1: working Red Team top bar and Zebar fix
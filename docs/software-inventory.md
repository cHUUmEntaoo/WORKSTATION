# WORKSTATION - Software Inventory

## Environment

- Operating System: Windows 11
- Shell: PowerShell 7
- Package Manager: WinGet 1.29.380
- Repository: WORKSTATION
- Primary Branch: main

## Core Components

| Software | WinGet ID | Detected Version |
|---|---|---|
| GlazeWM | glzr-io.glazewm | 3.10.1 |
| Zebar | glzr-io.zebar | 3.3.1 |
| JetBrainsMono Nerd Font | DEVCOM.JetBrainsMonoNerdFont | 3.3.0 |
| Windows Terminal | Microsoft.WindowsTerminal | 1.25.3131.0 |
| PowerShell | Microsoft.PowerShell | 7.6.9 |
| Oh My Posh | JanDeDobbeleer.OhMyPosh | 32.0.0 |
| Git | Git.Git | 2.56.0.4 |
| Visual Studio Code | Microsoft.VisualStudioCode | 1.146.0 |
| Mozilla Firefox | Mozilla.Firefox | 160.0 |

## Additional Components

| Software | WinGet ID | Detected Version |
|---|---|---|
| Node.js | OpenJS.NodeJS.LTS | 26.13.0 |
| Windows Subsystem for Linux | Microsoft.WSL | 3.0.5.0 |

## Zebar Verification

- Installed version: 3.3.1
- Executable: C:\Program Files\glzr.io\Zebar\zebar.exe
- Process status: Running
- Active configuration: $HOME\.glzr\zebar\settings.json
- Custom widget pack: WORKSTATION-BAR
- Installation method: WinGet (glzr-io.zebar)

## Nerd Font Verification

- Name: JetBrainsMono Nerd Font
- Version: 3.3.0
- WinGet ID: DEVCOM.JetBrainsMonoNerdFont
- License: SIL Open Font License 1.1

## Pending Verification

- Zebar installation automation using WinGet.
- WSL 2 verified; no Linux distributions installed.
- Windows Terminal profile portability.
- Software installation automation.
- Configuration restoration automation.
- Security review before committing files.
- GitHub repository publication.

## Repository Goals

1. Preserve working configurations.
2. Document software dependencies.
3. Automate installation and restoration.
4. Support migration to a new Windows 11 computer.
5. Avoid storing credentials and sensitive data.

## Security

- Do not commit passwords or API tokens.
- Do not commit private keys.
- Do not include browser profiles or sessions.
- Review configuration files before publication.



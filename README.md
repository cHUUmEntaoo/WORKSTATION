# WORKSTATION

Personal Windows 11 engineering and development workstation.

## Overview

WORKSTATION is a customized Windows 11 environment inspired
by Linux tiling window managers.

The project preserves configuration files and provides
PowerShell scripts for installation and restoration.

## Core Environment

- Windows 11
- PowerShell 7
- Windows Terminal
- GlazeWM
- Zebar / WORKSTATION-BAR
- Oh My Posh
- JetBrainsMono Nerd Font
- Git
- Visual Studio Code
- Mozilla Firefox

## Visual Design

- Theme: Catppuccin Mocha
- Terminal: Windows Terminal
- Prompt: Oh My Posh
- Window Manager: GlazeWM
- Status Bar: WORKSTATION-BAR
- Font: JetBrainsMono Nerd Font

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| Alt + Enter | Open Windows Terminal |
| Alt + Shift + C | Open Visual Studio Code |
| Alt + Shift + F | Open Firefox |
| Alt + 1 through 9 | Switch workspace |
| Alt + Shift + 1 through 9 | Move window to workspace |
| Alt + H/J/K/L | Focus windows |

## Repository Structure

- configs/glazewm: GlazeWM configuration
- configs/zebar: Zebar custom bar and settings
- configs/powershell: PowerShell profile and prompt theme
- configs/windows-terminal: Terminal settings
- scripts/install: Software installation scripts
- scripts/restore: Configuration restoration scripts
- scripts/setup: Workstation setup utilities
- docs: Technical documentation
- assets: Project assets

## Software Verification

Run from the repository root:

    ./scripts/install/install-core.ps1

This checks the core software without installing packages.

The -Install mode has not yet been validated.

## Configuration Restoration

Available scripts:

    ./scripts/restore/restore-glazewm.ps1
    ./scripts/restore/restore-zebar.ps1
    ./scripts/restore/restore-powershell.ps1
    ./scripts/restore/restore-windows-terminal.ps1

Running without -Apply checks existing configurations.

Restoration with -Apply must be validated separately.

## Windows Subsystem for Linux

WSL 2 is available.

No Linux distributions are currently installed.

## Security

- Never commit passwords, tokens or private keys.
- Never commit browser sessions or user profiles.
- Review configuration files before publication.
- Start with a private GitHub repository.
- Keep configuration backups outside the repository.
- Verify restoration scripts before applying changes.

## Project Status

WORKSTATION v1.0 preparation.

Installation verification: Completed.
Configuration comparison: Completed.
Automatic startup: Pending.
Restoration application testing: Pending.
GitHub publication: Pending.

## Goal

Rebuild a productive Windows 11 workstation on another
computer with minimal manual configuration.

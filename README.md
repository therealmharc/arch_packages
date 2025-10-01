# Arch Linux Package Installer
Automates installation of packages from official repositories and AUR with theme configuration.

## Features
- Installs packages from official Arch repositories
- Handles AUR packages using paru helper
- Applies consistent theme settings
- Provides user-friendly prompts and feedback
- Offers optional reboot after completion

## Usage

### One-line installation:
```bash
curl -Ls bit.ly/trm-arch-packages | bash
```

### Manual installation:
- Clone the repository or download the script.
- Make the script executable: `chmod +x packages.sh`
- Run the script: `./packages.sh`

## Packages

### Official Repository
- Development tools
- Graphics applications
- Office suite
- Utilities
- GNOME applications and extensions

### AUR Packages
- Additional browsers
- Development tools
- System utilities
- Communication apps

## Theme Configuration
Sets the following visual elements:
- Icons: Papirus
- Cursor: Bibata-Modern-Ice

## Requirements
- Arch Linux installation
- Internet connection
- sudo privileges

## Notes
- Script will install paru if not present
- System updates are performed before package installation
- Reboot recommended for all changes to take effect

# XAMPP / Laravel installation (Extras):
```bash
curl -Ls bit.ly/trm-xampp-install | bash
```

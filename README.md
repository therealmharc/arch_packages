# Arch Linux Package Installer

A bash script to automate the installation of packages on Arch Linux from both official repositories and the AUR (using paru).

## Features

- Installs paru (AUR helper) if not present
- Updates the system
- Installs a curated list of packages from official repositories
- Installs a curated list of packages from the AUR

## Usage

### One-line installation:
```bash
curl -Ls bit.ly/trm-arch-packages | bash
```

### Manual installation:
1. Clone the repository or download the script.
2. Make the script executable: `chmod +x packages.sh`
3. Run the script: `./packages.sh`

## Note

- This script should not be run as root.
- It is always recommended to review the script before running it on your system.

## Package Lists

The script installs a variety of packages including:
- Development tools (nodejs, npm, composer)
- Graphics and design (gimp, inkscape, krita)
- Utilities (android-tools, aria2, meld)
- GNOME extensions and tweaks
- And more...

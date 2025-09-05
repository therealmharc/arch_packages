#!/bin/bash

# Arch Linux Package Installer Script
# This script installs packages from both official repositories (pacman) and AUR (paru)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Check if paru is installed
check_paru() {
    if ! command -v paru &> /dev/null; then
        print_status "paru (AUR helper) not found. Installing paru..."
        
        # Install paru dependencies
        sudo pacman -S --needed --noconfirm base-devel git
        
        # Clone and install paru
        cd /tmp
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ..
        rm -rf paru
        
        print_success "paru installed successfully"
    else
        print_status "paru is already installed"
    fi
}

# Update system before installation
update_system() {
    print_status "Updating system..."
    sudo pacman -Syu --noconfirm
    print_success "System updated"
}

# Install packages from official repositories
install_pacman_packages() {
    local packages=(
        "amberol"
        "android-tools"
        "aria2"
        "audacity"
        "balsa"
        "chromium"
        "code"
        "composer"
        "discord"
        "epiphany"
        "file-roller"
        "gimp"
        "gnome-boxes"
        "gnome-calculator"
        "gnome-calendar"
        "gnome-clocks"
        "gnome-disk-utility"
        "gnome-firmware"
        "gnome-multi-writer"
        "gnome-tweaks"
        "gthumb"
        "inkscape"
        "jp2a"
        "krita"
        "krita-plugin-gmic"
        "libreoffice-fresh"
        "meld"
        "nodejs"
        "npm"
        "noto-fonts-cjk"
        "noto-fonts-extra"
        "papirus-icon-theme"
        "showtime"
        "snapshot"
        "speedtest-cli"
        "sshpass"
        "telegram-desktop"
    )
    
    print_status "Installing packages from official repositories..."
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    
    # Conditionally remove tela-circle-icon-theme-standard
    if pacman -Qi tela-circle-icon-theme-standard &> /dev/null; then
        sudo pacman -R --noconfirm tela-circle-icon-theme-standard
    fi
    
    print_success "Official repository packages installed"
}

# Install packages from AUR using paru
install_aur_packages() {
    local packages=(
        "android-sdk-build-tools"
        "bibata-cursor-theme"
        "downgrade"
        "extension-manager"
        "gdm-settings"
        "gnome-network-displays"
        "google-chrome"
        "opera"
        "sublime-text-4"
        "whatsie"
    )
    
    print_status "Installing packages from AUR..."
    paru -S --needed --noconfirm "${packages[@]}"
    print_success "AUR packages installed"
}

# Main execution
main() {
    print_status "Starting package installation..."
    
    # Check and install paru if needed
    check_paru
    
    # Update system
    update_system
    
    # Install packages
    install_pacman_packages
    install_aur_packages
    
    print_success "All packages installed successfully!"
    print_status "You may want to reboot your system for all changes to take effect."
}

# Run the main function
main "$@"

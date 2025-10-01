#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

check_paru() {
    if ! command -v paru &> /dev/null; then
        print_status "paru (AUR helper) not found. Installing paru..."
        sudo pacman -S --needed --noconfirm base-devel git
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

restart_reflector() {
    print_status "Restarting reflector service to update mirrors..."
    sudo systemctl restart reflector.service
    print_success "Reflector service restarted"
}

update_system() {
    print_status "Updating system..."
    sudo pacman -Syu --noconfirm
    print_success "System updated"
}

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
        "gnome-weather"
        "gthumb"
        "inkscape"
        "jp2a"
        "krita"
        "krita-plugin-gmic"
        "libreoffice-fresh"
        "meld"
        "noto-fonts-cjk"
        "noto-fonts-extra"
        "papirus-icon-theme"
        "snapshot"
        "speedtest-cli"
        "sshpass"
        "telegram-desktop"
    )
    
    print_status "Installing packages from official repositories..."
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    print_success "Official repository packages installed"
}

install_aur_packages() {
    local packages=(
        "android-sdk-build-tools"
        "bibata-cursor-theme"
        "downgrade"
        "extension-manager"
        "gdm-settings"
        "gnome-network-displays"
        "google-chrome"
        "sublime-text-4"
        "whatsie"
    )
    
    print_status "Installing packages from AUR..."
    paru -S --needed --noconfirm "${packages[@]}"
    print_success "AUR packages installed"
}

apply_themes() {
    print_status "Removing tela-circle-icon-theme-standard if installed..."
    if pacman -Qi tela-circle-icon-theme-standard &> /dev/null; then
        sudo pacman -R --noconfirm tela-circle-icon-theme-standard
        print_success "tela-circle-icon-theme-standard removed"
    fi
    
    print_status "Applying theme settings..."
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    print_success "Theme settings applied"
}

install_xampp() {
    print_status "Checking if user wants to install XAMPP..."
    read -p "Do you want to install XAMPP? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installing XAMPP..."
        curl -Ls bit.ly/trm-xampp-install | bash
        print_success "XAMPP installation completed"
    else
        print_status "XAMPP installation skipped"
    fi
}

reboot_prompt() {
    echo
    print_status "Installation complete! Some changes may require a reboot to take effect."
    read -p "Do you want to reboot now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Rebooting system..."
        sudo systemctl reboot
    else
        print_status "Reboot skipped. You can reboot manually later with: sudo systemctl reboot"
    fi
}

main() {
    print_status "Starting package installation..."
    check_paru
    restart_reflector
    update_system
    install_pacman_packages
    install_aur_packages
    apply_themes
    install_xampp
    print_success "All packages installed successfully!"
    reboot_prompt
}

main "$@"
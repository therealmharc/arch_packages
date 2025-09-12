#!/bin/bash

# Arch Linux Package Installer Script
# This script installs packages from both official repositories (pacman) and AUR (paru)
# After installation, it configures themes and extensions

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
        "gnome-shell-extension-user-themes"
        "google-chrome"
        "opera"
        "sublime-text-4"
        "whatsie"
    )
    
    print_status "Installing packages from AUR..."
    paru -S --needed --noconfirm "${packages[@]}"
    print_success "AUR packages installed"
}

# Apply theme configurations
apply_themes() {
    print_status "Applying theme configurations..."
    
    # Enable User Themes extension (required for custom shell themes)
    if gnome-extensions list | grep -q "user-theme@gnome-shell-extensions.gcampax.github.com"; then
        gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
        print_success "User Themes extension enabled"
    else
        print_warning "User Themes extension not found. Please install it manually from https://extensions.gnome.org/extension/19/user-themes/"
    fi
    
    # Set icon theme to Papirus
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
    
    # Set cursor theme to Bibata-Modern-Ice
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    
    # Explicitly set shell theme to Adwaita (default)
    gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    
    print_success "Theme configuration applied:"
    print_status "  Icons: Papirus"
    print_status "  Cursor: Bibata-Modern-Ice"
    print_status "  Shell: Adwaita (default)"
    print_status "  Legacy Applications: Adwaita (default)"
}

# Prompt for reboot
prompt_reboot() {
    echo
    print_status "Package installation and configuration completed!"
    
    while true; do
        read -p "$(print_status "Do you want to reboot now? (Y/N): ")" yn
        case $yn in
            [Yy]* ) 
                print_status "Rebooting system..."
                sudo systemctl reboot
                break
                ;;
            [Nn]* ) 
                print_status "You may need to reboot later for all changes to take effect."
                break
                ;;
            * ) 
                print_error "Please answer yes (Y) or no (N)."
                ;;
        esac
    done
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
    
    # Apply theme configurations
    apply_themes
    
    # Prompt for reboot
    prompt_reboot
}

# Run the main function
main "$@"

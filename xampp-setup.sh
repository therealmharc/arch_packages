#!/bin/bash
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_debug() { echo -e "${CYAN}[DEBUG]${NC} $1"; }

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a normal user, not as root."
    exit 1
fi

# Check if we're on Arch Linux
if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
    print_warning "This script is primarily designed for Arch Linux. Continue at your own risk."
    # Only prompt if we have an interactive terminal
    if [ -t 0 ] && [ -t 1 ]; then
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_error "Non-Arch Linux detected in non-interactive mode. Aborting."
        exit 1
    fi
fi

# Check for required tools
check_dependencies() {
    local deps=("wget" "sudo")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_status "Installing missing dependencies: ${missing[*]}"
        sudo pacman -S --noconfirm "${missing[@]}"
    fi
}

# Download XAMPP with retry logic
download_xampp() {
    local download_url="https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run"
    local output_file="xampp-installer.run"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        print_status "Downloading XAMPP... (Attempt $((retry_count + 1))/$max_retries)"
        if wget --show-progress -O "$output_file" "$download_url"; then
            chmod +x "$output_file"
            print_success "XAMPP downloaded successfully"
            return 0
        else
            retry_count=$((retry_count + 1))
            print_warning "Download failed. Retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    print_error "Failed to download XAMPP after $max_retries attempts"
    exit 1
}

# Verify downloaded file
verify_download() {
    local file="xampp-installer.run"
    
    if [ ! -f "$file" ]; then
        print_error "Downloaded file not found: $file"
        exit 1
    fi
    
    if [ ! -s "$file" ]; then
        print_error "Downloaded file is empty"
        exit 1
    fi
    
    local file_size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
    if [ "$file_size" -lt 1000000 ]; then
        print_error "Downloaded file seems too small ($file_size bytes). May be corrupted."
        exit 1
    fi
    
    print_success "Download verification passed"
}

# Install XAMPP
install_xampp() {
    print_status "Running XAMPP installer (requires root password)..."
    
    # Check if XAMPP is already installed
    if [ -f "/opt/lampp/lampp" ]; then
        print_warning "XAMPP appears to be already installed at /opt/lampp"
        # Only prompt if we have an interactive terminal
        if [ -t 0 ] && [ -t 1 ]; then
            read -p "Do you want to reinstall? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Skipping XAMPP installation"
                return 0
            fi
        else
            print_warning "Non-interactive shell. Skipping reinstallation of existing XAMPP."
            return 0
        fi
    fi
    
    if ! sudo ./xampp-installer.run; then
        print_error "XAMPP installation failed"
        exit 1
    fi
    
    print_success "XAMPP installed successfully"
}

# Configure passwordless sudo for XAMPP manager
configure_sudo() {
    local sudo_file="/etc/sudoers.d/xampp-manager"
    
    print_status "Configuring passwordless sudo for XAMPP manager..."
    
    # Check if already configured
    if [ -f "$sudo_file" ] && sudo grep -q "$USER" "$sudo_file" 2>/dev/null; then
        print_status "XAMPP sudo configuration already exists"
        return 0
    fi
    
    echo "$USER ALL=(ALL) NOPASSWD: /opt/lampp/manager-linux-x64.run" | sudo tee "$sudo_file" > /dev/null
    sudo chmod 0440 "$sudo_file"
    
    # Verify the configuration
    if sudo visudo -c -f "$sudo_file"; then
        print_success "Sudo configuration applied successfully"
    else
        print_error "Sudo configuration validation failed"
        sudo rm -f "$sudo_file"
        exit 1
    fi
}

# Enable PHP extensions
enable_php_extensions() {
    local xampp_php_ini="/opt/lampp/etc/php.ini"
    local system_php_ini="/etc/php/php.ini"
    
    print_status "Enabling PHP extensions..."
    
    # Enable extensions in XAMPP's php.ini (primary)
    if [ -f "$xampp_php_ini" ]; then
        sudo sed -i 's/^;extension=iconv/extension=iconv/' "$xampp_php_ini"
        sudo sed -i 's/^;extension=mysqli/extension=mysqli/' "$xampp_php_ini"
        sudo sed -i 's/^;extension=pdo_mysql/extension=pdo_mysql/' "$xampp_php_ini"
        sudo sed -i 's/^;extension=openssl/extension=openssl/' "$xampp_php_ini"
        sudo sed -i 's/^;extension=mbstring/extension=mbstring/' "$xampp_php_ini"
        sudo sed -i 's/^;extension=curl/extension=curl/' "$xampp_php_ini"
        print_success "Enabled PHP extensions in XAMPP php.ini"
    else
        print_warning "XAMPP php.ini not found at $xampp_php_ini"
    fi
    
    # Also enable in system php.ini if it exists
    if [ -f "$system_php_ini" ]; then
        sudo sed -i 's/^;extension=iconv/extension=iconv/' "$system_php_ini"
        sudo sed -i 's/^;extension=mysqli/extension=mysqli/' "$system_php_ini"
        sudo sed -i 's/^;extension=pdo_mysql/extension=pdo_mysql/' "$system_php_ini"
        print_success "Enabled PHP extensions in system php.ini"
    else
        print_status "System php.ini not found at $system_php_ini (this is normal for XAMPP-only installations)"
    fi
}

# Create desktop entry
create_desktop_entry() {
    local desktop_file="$HOME/.local/share/applications/xampp-manager.desktop"
    local icon_file="/opt/lampp/htdocs/favicon.ico"
    
    print_status "Creating desktop entry..."
    
    # Check if icon exists, use fallback if not
    if [ ! -f "$icon_file" ]; then
        icon_file="/usr/share/icons/gnome/256x256/apps/system.png"
        print_warning "XAMPP icon not found, using fallback icon"
    fi
    
    mkdir -p ~/.local/share/applications
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=XAMPP Manager
Comment=XAMPP Control Panel GUI
Exec=sudo /opt/lampp/manager-linux-x64.run
Icon=$icon_file
Categories=Development;
Terminal=false
StartupNotify=true
Keywords=xampp;apache;mysql;php;web;development
EOF

    if [ -f "$desktop_file" ]; then
        print_success "Desktop entry created at $desktop_file"
    else
        print_error "Failed to create desktop entry"
    fi
}

# Install Laravel dependencies
install_laravel_deps() {
    print_status "Installing Laravel dependencies..."
    
    local deps=("composer" "nodejs" "npm" "libxcrypt-compat")
    local missing=()
    
    # Check which dependencies are missing
    for dep in "${deps[@]}"; do
        if ! pacman -Qi "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_status "Installing: ${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
        print_success "Laravel dependencies installed"
    else
        print_status "All Laravel dependencies are already installed"
    fi
}

# Configure Composer PATH
configure_composer_path() {
    print_status "Configuring Composer PATH..."
    
    # Configure for Bash
    local bashrc_line='export PATH="$PATH:$HOME/.config/composer/vendor/bin"'
    if ! grep -q '.config/composer/vendor/bin' ~/.bashrc; then
        echo "$bashrc_line" >> ~/.bashrc
        print_success "Added Composer to Bash PATH"
    else
        print_status "Composer already in Bash PATH"
    fi
    
    # Configure for Fish shell
    if command -v fish &> /dev/null && [ -d ~/.config/fish ]; then
        if ! fish -c "echo \$fish_user_paths" | grep -q 'composer/vendor/bin'; then
            fish -c "set -U fish_user_paths \$HOME/.config/composer/vendor/bin \$fish_user_paths"
            print_success "Added Composer to Fish shell PATH"
        else
            print_status "Composer already in Fish shell PATH"
        fi
    fi
    
    # Source bashrc to make Composer available immediately
    source ~/.bashrc 2>/dev/null || true
}

# Install Laravel installer
install_laravel() {
    print_status "Installing Laravel installer globally..."
    
    # Ensure Composer is in PATH
    export PATH="$PATH:$HOME/.config/composer/vendor/bin"
    
    if composer global require laravel/installer; then
        print_success "Laravel installer installed successfully"
        
        # Verify installation
        if command -v laravel &> /dev/null; then
            print_success "Laravel command is now available"
        else
            print_warning "Laravel command may not be in PATH. Try opening a new terminal or run: source ~/.bashrc"
        fi
    else
        print_error "Failed to install Laravel installer"
        exit 1
    fi
}

# Display post-installation information
show_post_install_info() {
    echo
    print_success "XAMPP and Laravel installation complete!"
    echo
    echo -e "${CYAN}Next steps:${NC}"
    echo "1. Start XAMPP: /opt/lampp/lampp start"
    echo "2. Launch XAMPP Manager from your application menu or run: sudo /opt/lampp/manager-linux-x64.run"
    echo "3. Create a new Laravel project: laravel new project-name"
    echo "4. Place your projects in: /opt/lampp/htdocs/"
    echo
    echo -e "${YELLOW}Important notes:${NC}"
    echo "• XAMPP Manager can be launched without password from the application menu"
    echo "• MySQL data directory: /opt/lampp/var/mysql"
    echo "• Web root directory: /opt/lampp/htdocs"
    echo "• PHP configuration: /opt/lampp/etc/php.ini"
    echo "• You may need to restart your terminal or run 'source ~/.bashrc' for Laravel command"
    echo
}

# Cleanup function
cleanup() {
    if [ -f "xampp-installer.run" ]; then
        print_status "Cleaning up installer file..."
        rm -f xampp-installer.run
    fi
}

# Main execution
main() {
    print_status "Starting XAMPP and Laravel development environment setup..."
    
    # Set trap for cleanup on exit
    trap cleanup EXIT
    
    check_dependencies
    download_xampp
    verify_download
    install_xampp
    configure_sudo
    enable_php_extensions
    create_desktop_entry
    install_laravel_deps
    configure_composer_path
    install_laravel
    show_post_install_info
}

# Run main function
main "$@"
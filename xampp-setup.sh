#!/bin/bash
set -e

print_status() {
    echo -e "\033[1;34m==> \033[1;37m$1\033[0m"
}

if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a normal user, not as root."
    exit 1
fi

print_status "Downloading XAMPP..."
wget -O xampp-installer.run "https://sourceforge.net/projects/xampp/files/XAMPP%20Linux/8.2.12/xampp-linux-x64-8.2.12-0-installer.run"
chmod +x xampp-installer.run

print_status "Running XAMPP installer (requires root password)..."
sudo ./xampp-installer.run

print_status "Configuring passwordless sudo for XAMPP manager..."
echo "$USER ALL=(ALL) NOPASSWD: /opt/lampp/manager-linux-x64.run" | sudo tee /etc/sudoers.d/xampp-manager
sudo chmod 0440 /etc/sudoers.d/xampp-manager

print_status "Enabling PHP extensions in system php.ini..."
SYSTEM_PHP_INI="/etc/php/php.ini"
if [ -f "$SYSTEM_PHP_INI" ]; then
    sudo sed -i 's/^;extension=iconv/extension=iconv/' "$SYSTEM_PHP_INI"
    sudo sed -i 's/^;extension=mysqli/extension=mysqli/' "$SYSTEM_PHP_INI"
    sudo sed -i 's/^;extension=pdo_mysql/extension=pdo_mysql/' "$SYSTEM_PHP_INI"
    print_status "Enabled iconv and mysqli extensions in system PHP configuration"
else
    print_status "Note: System php.ini not found at $SYSTEM_PHP_INI"
fi

print_status "Creating desktop entry..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/xampp-manager.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=XAMPP Manager
Comment=XAMPP Control Panel GUI
Exec=sudo /opt/lampp/manager-linux-x64.run
Icon=/opt/lampp/htdocs/favicon.ico
Categories=Development;
Terminal=false
StartupNotify=true
Keywords=xampp;apache;mysql;php;web;development
EOF

print_status "Installing Laravel dependencies (composer, nodejs, npm)..."
sudo pacman -S --noconfirm composer nodejs npm libxcrypt-compat

if ! grep -q '.config/composer/vendor/bin' ~/.bashrc; then
    print_status "Adding Composer to Bash PATH..."
    echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc
fi

if command -v fish &> /dev/null && [ -d ~/.config/fish ]; then
    print_status "Adding Composer to Fish shell PATH..."
    fish -c "set -Ux fish_user_paths \$HOME/.config/composer/vendor/bin \$fish_user_paths"
fi

source ~/.bashrc 2>/dev/null || true

print_status "Installing Laravel installer globally..."
composer global require laravel/installer

print_status "Installation complete!"

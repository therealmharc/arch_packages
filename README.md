# Arch Linux Development Environment Installer

Automates installation of essential packages, development tools, and applications from official Arch repositories and AUR with comprehensive development environment setup.

## Features

- **Automatic AUR Helper Setup**: Installs `paru` if not present
- **System Preparation**: Updates system packages and refreshes mirror list
- **Comprehensive Package Installation**: 
  - Official repository packages (development, graphics, office, utilities)
  - AUR packages (additional tools and applications)
- **Theme Configuration**: Applies consistent icon and cursor themes
- **Complete Development Stack**: Optional XAMPP with Laravel environment
- **User-Friendly Interface**: Color-coded status messages and interactive prompts
- **Post-Installation Options**: Optional system reboot for changes to take effect

## Quick Installation

### Complete Package Installation (Official + AUR):
```bash
curl -Ls bit.ly/trm-arch-packages | bash
```

### Development Environment (XAMPP + Laravel):
```bash
curl -Ls bit.ly/trm-xampp-install | bash
```

## Manual Installation

1. Download the script:
   ```bash
   wget https://example.com/packages.sh
   ```

2. Make executable:
   ```bash
   chmod +x packages.sh
   ```

3. Run the installer:
   ```bash
   ./packages.sh
   ```

## Package Categories

### Official Repository Packages
- **Development**: `android-tools`, `code`, `composer`, `meld`
- **Graphics**: `gimp`, `inkscape`, `krita`, `krita-plugin-gmic`
- **Office**: `libreoffice-fresh`
- **Utilities**: `aria2`, `gnome-disk-utility`, `speedtest-cli`, `sshpass`
- **GNOME Applications**: `amberol`, `epiphany`, `gnome-boxes`, `gnome-tweaks`
- **Communication**: `discord`, `telegram-desktop`
- **Fonts**: `noto-fonts-cjk`, `noto-fonts-extra`

### AUR Packages
- **Development**: `android-sdk-build-tools`, `sublime-text-4`
- **Browsers**: `google-chrome`
- **System Tools**: `downgrade`, `extension-manager`, `gdm-settings`
- **Communication**: `whatsie`
- **GNOME Extensions**: `gnome-network-displays`

## Theme Configuration

The script automatically configures:
- **Icons**: Papirus icon theme
- **Cursor**: Bibata-Modern-Ice cursor theme

## XAMPP & Laravel Development Stack

The enhanced XAMPP installation now includes:

### 🚀 **XAMPP Stack**
- **Full LAMP Stack**: Apache, MySQL, PHP 8.2.12
- **Secure Installation**: Download verification and retry logic
- **Smart Detection**: Checks for existing installations with reinstall prompts

### 🔧 **Enhanced PHP Configuration**
- **Essential Extensions**: iconv, mysqli, pdo_mysql, openssl, mbstring, curl
- **Dual Configuration**: Both XAMPP and system PHP.ini files updated
- **Production Ready**: Common extensions enabled for Laravel development

### 🛡️ **Security & Permissions**
- **Passwordless Sudo**: Secure configuration for XAMPP manager
- **Sudo Validation**: Automatic validation using `visudo -c`
- **Safe Operations**: Comprehensive error handling and rollback

### 🎯 **Development Environment**
- **Laravel Ready**: Composer, Node.js, npm, libxcrypt-compat
- **Multi-Shell Support**: Automatic PATH configuration for Bash and Fish
- **Global Tools**: Laravel installer with verification

### 🖥️ **Desktop Integration**
- **Application Launcher**: Desktop entry with fallback icon support
- **Easy Access**: Launch XAMPP manager from application menu
- **User-Friendly**: No terminal commands needed for daily use

### 📋 **Post-Installation Guide**
- **Clear Next Steps**: Startup commands and project locations
- **Important Paths**: MySQL data, web root, PHP configuration
- **Troubleshooting**: Common issues and solutions

## Installation Process

### For XAMPP/Laravel Setup:
1. **Dependency Check**: Automatically installs missing tools (wget, sudo)
2. **Download with Retry**: 3 attempts with progress indicators
3. **File Verification**: Size and integrity checks
4. **Smart Installation**: Detects existing installations with reinstall options
5. **Configuration**: PHP extensions, sudo permissions, desktop integration
6. **Laravel Setup**: Dependencies, Composer configuration, global installer
7. **Verification**: Checks installation success and provides next steps

## Requirements

- **OS**: Arch Linux (primary), with warnings for other distributions
- **Privileges**: sudo access for package installation
- **Internet**: Stable connection for downloading packages (~200MB for XAMPP)
- **Storage**: Sufficient disk space (~500MB for XAMPP + dependencies)

## Script Safety Features

- **Root Prevention**: Cannot run as root user
- **Error Handling**: `set -e` with comprehensive error messages
- **Validation**: File checks, sudo configuration validation
- **Cleanup**: Automatic removal of temporary files
- **Confirmation Prompts**: User confirmation for risky operations

## Post-Installation

### After Package Installation:
1. **Reboot recommended** for all theme changes and system updates
2. **Verify installations** by checking installed applications
3. **Configure additional settings** in GNOME Tweaks if needed

### After XAMPP Installation:
1. **Start XAMPP**: `/opt/lampp/lampp start`
2. **Launch Manager**: Use desktop application or `sudo /opt/lampp/manager-linux-x64.run`
3. **Create Projects**: Place web projects in `/opt/lampp/htdocs/`
4. **Laravel Development**: Use `laravel new project-name` command

## Troubleshooting

### Common Issues:
- **AUR packages fail**: Ensure `paru` is properly installed
- **XAMPP permissions**: Check `/etc/sudoers.d/xampp-manager`
- **Theme changes**: May require logging out and back in
- **Laravel command not found**: Run `source ~/.bashrc` or restart terminal
- **Download failures**: Script includes retry logic; check internet connection

### XAMPP Specific:
- **Port conflicts**: Check if other web servers are running
- **MySQL issues**: Verify data directory permissions at `/opt/lampp/var/mysql`
- **PHP errors**: Check configuration at `/opt/lampp/etc/php.ini`

## File Structure

- `packages.sh` - Main package installer script
- `xampp-setup.sh` - Enhanced XAMPP and Laravel development environment
- `README.md` - This documentation file

## Notes

- Script performs full system update before package installation
- Existing packages are skipped (--needed flag)
- XAMPP installation is optional and user-confirmed
- Some GNOME extensions may require manual configuration
- Laravel development environment includes all common PHP extensions

## Support

For issues with the installation scripts:
1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Ensure you have a stable internet connection
4. Review the output messages for specific error information

---

**Note**: These scripts are designed for fresh Arch Linux installations and include comprehensive error handling for reliable setup of development environments.
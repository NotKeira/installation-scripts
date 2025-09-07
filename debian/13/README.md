# Debian 13 Installation Scripts

Installation scripts specifically designed and tested for Debian 13 (Trixie). These scripts automate the installation of desktop environments, window managers, and related software packages.

## System Requirements

- **Operating System**: Debian 13 (Trixie)
- **Architecture**: x86_64 (amd64)
- **Privileges**: sudo access required
- **Internet**: Active connection for package downloads and repository cloning
- **Disk Space**: Minimum 2GB free space for build processes

## Available Scripts

### Hyprland Wayland Compositor

Complete installation suite for Hyprland, a dynamic tiling Wayland compositor.

**Location**: `hyprland/`

**Scripts**:
- `install.sh` - Production installation script
- `install-demo.sh` - Demonstration version for testing

**What's Included**:
- All build dependencies and development libraries
- Latest stable Hyprland build from source
- Essential Hypr ecosystem components (hyprutils, hyprlang, etc.)
- Basic configuration file setup
- Post-installation system configuration

**Installation Time**: 15-30 minutes depending on system specifications

## Quick Installation

### Hyprland
```bash
cd hyprland
chmod +x install.sh
./install.sh
```

#### Testing (Demo Mode)
```bash
cd hyprland
chmod +x install-demo.sh
./install-demo.sh
```

## Pre-Installation Checklist

Before running any installation script:

1. **System Update**: Ensure your system is up to date
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Backup**: Create system backups if running on production systems

3. **Dependencies**: Verify you have `sudo` privileges and internet connectivity

4. **Disk Space**: Check available disk space with `df -h`

5. **Review**: Read the specific script documentation in each subdirectory

## Post-Installation

After successful installation:

1. **Reboot**: Restart your system to ensure all changes take effect
2. **Configuration**: Review and customise configuration files
3. **Additional Software**: Install complementary applications as needed
4. **Documentation**: Consult official documentation for advanced configuration

## Troubleshooting

### Common Issues

**Build Failures**:
- Ensure all system packages are updated
- Verify sufficient disk space (2GB+ recommended)
- Check internet connectivity for repository access

**Permission Errors**:
- Confirm sudo access: `sudo -v`
- Ensure user is in sudoers group: `groups $USER`

**Missing Dependencies**:
- Scripts install all required dependencies automatically
- If issues persist, manually run system update first

### Getting Help

1. **Logs**: Check script output for specific error messages
2. **Documentation**: Consult the specific README in each script directory
3. **Issues**: Report problems on the GitHub repository
4. **Community**: Seek help in relevant communities (Debian, Hyprland forums)

## Compatibility

These scripts are specifically designed for:
- **Debian 13 (Trixie)** - Primary target
- **Fresh installations** - Recommended for best results
- **Standard repositories** - Uses official Debian packages where possible

**Not tested on**:
- Debian derivatives (Ubuntu, Linux Mint, etc.)
- Older Debian versions
- Mixed package environments

## Contributing

When contributing Debian-specific scripts:

1. **Testing**: Verify compatibility with clean Debian 13 installations
2. **Dependencies**: Use official Debian repositories when possible
3. **Documentation**: Include comprehensive README files
4. **Standards**: Follow the established script patterns and error handling

## Security Notes

- Scripts require root privileges for system package installation
- All source code is downloaded from official repositories
- Review scripts before execution, especially on production systems
- Consider testing in virtual machines first

---

For specific installation instructions and detailed information, see the README files in each subdirectory.

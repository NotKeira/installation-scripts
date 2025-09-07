# Installation Scripts

A comprehensive collection of automated installation scripts for various operating systems, desktop environments, and software packages. These scripts are designed to streamline system setup and software deployment with proper error handling, user prompts, and visual feedback.

## Features

- **Modular Architecture**: Each script is self-contained and purpose-built
- **Interactive Installation**: Permission prompts before each major operation
- **Visual Feedback**: Colourful output with progress indicators and status messages
- **Error Handling**: Comprehensive error checking and automatic cleanup on failure
- **Production Ready**: Tested and optimised for reliability and performance

## Repository Structure

```
installation-scripts/
├── debian/
│   ├── hyprland/
│   │   ├── install.sh          # Complete Hyprland installation
│   │   ├── install-demo.sh     # Demo version for testing
│   │   └── README.md
│   └── README.md
├── arch/                       # (Future)
├── fedora/                     # (Future)
└── README.md
```

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/NotKeira/installation-scripts.git
   cd installation-scripts
   ```

2. Navigate to your OS directory:
   ```bash
   cd debian  # or your target OS
   ```

3. Review the relevant README for specific installation instructions

4. Make scripts executable and run:
   ```bash
   chmod +x script-name.sh
   ./script-name.sh
   ```

## Current Scripts

### Debian 13
- **Hyprland**: Complete installation of Hyprland Wayland compositor with all dependencies
  - Full production installation script
  - Demo version for testing and demonstrations

## Script Standards

All scripts in this repository follow these standards:

- **Bash compatibility**: Written for bash shell with proper shebang
- **Error handling**: `set -e` and comprehensive error checking
- **User interaction**: Clear prompts before destructive operations
- **Logging**: Detailed output with colour-coded status messages
- **Cleanup**: Automatic cleanup on failure or completion
- **Documentation**: Comprehensive inline comments and external README files

## Contributing

Contributions are welcome! Please ensure new scripts follow the established patterns:

1. Include proper error handling and user prompts
2. Add comprehensive documentation
3. Test thoroughly before submitting
4. Follow the existing directory structure
5. Include both production and demo versions where applicable

## Security Considerations

- **Review scripts** before execution, especially those requiring root privileges
- **Understand dependencies** being installed on your system
- **Backup important data** before running system-level installation scripts
- **Test in virtual machines** when possible before production use

## Licence

This project is licensed under the MIT Licence - see the [LICENCE](LICENCE) file for details.

## Author

**NotKeira** - [GitHub](https://github.com/NotKeira)

## Support

For issues, questions, or contributions, please open an issue on GitHub or submit a pull request.

---

*These scripts are provided as-is. Always review and understand scripts before execution, particularly those requiring administrative privileges.*

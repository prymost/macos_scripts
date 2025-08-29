# Bootstrap Scripts

Automated setup scripts for my personal machines across multiple platforms

## Quick Start

```bash
# Windows 11 (as Administrator)
PowerShell -ExecutionPolicy Bypass -File windows/bootstrap-windows11.ps1

# macOS
./mac/bootstrap.sh

# WSL Ubuntu
./windows/wsl_scripts/bootstrap.sh

# PopOS/Debian Linux
./linux/debian/bootstrap.sh
```

## How It Works

Each platform has its own optimized approach:

- **Windows**: Uses existing WingetApps module with inline application list for reliability
- **macOS**: Uses static Brewfile for traditional Homebrew workflow
- **WSL Ubuntu**: Direct package arrays for simplicity and speed
- **PopOS/Debian**: Direct package arrays with special installation handling for complex apps

All scripts are designed to be platform-specific, simple, and maintainable without shared dependencies.

## Platform Details

- [mac/README.md](mac/README.md) - macOS setup with Homebrew
- [windows/README.md](windows/README.md) - Windows 11 bootstrap with interactive menu
- [windows/wsl_scripts/README.md](windows/wsl_scripts/README.md) - WSL Ubuntu development environment
- [linux/debian/README.md](linux/debian/README.md) - PopOS/Debian desktop setup (coming soon)
- [shared/](shared/) - Shared configuration templates (currently .zshrc for macOS)

## Supported Platforms

- ✅ **Windows 11** - Full desktop bootstrap with WSL2
- ✅ **macOS** - Apple Silicon & Intel support
- ✅ **WSL Ubuntu** - Development environment in Windows
- ✅ **PopOS/Debian** - Linux desktop replacement

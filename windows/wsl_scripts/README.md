# WSL Ubuntu Setup Scripts

My personal scripts for setting up and maintaining a fresh WSL Ubuntu installation with development tools and configurations.

## 🚀 Quick Start

1. **Install WSL Ubuntu** (if not already done):
   ```powershell
   # In Windows PowerShell (as Administrator)
   wsl --install Ubuntu
   ```

2. **Run compatibility check** (recommended):
   ```bash
   ./check_compatibility.sh
   ```

3. **Run full bootstrap**:
   ```bash
   ./bootstrap.sh
   ```

## 📁 Script Overview

- **`bootstrap.sh`** - Main entry point that orchestrates the entire setup
- **`check_compatibility.sh`** - Validates WSL and system compatibility before setup
- **`setup/initial.sh`** - Installs core tools, Homebrew, Docker, and essential packages
- **`setup/my_installs.sh`** - Installs development tools, languages, and applications
- **`setup/configure_linux.sh`** - Configures shell, aliases, Git, and development environment
- **`setup/restore.sh`** - Restores backed-up configuration files
- **`packages.txt`** - Reference list of installed packages

## 🛠️ What Gets Installed

### Core Tools
- **Package Managers**: Homebrew (Linuxbrew), APT
- **Containers**: Docker with Docker Compose
- **Version Control**: Git, GitHub CLI
- **Cloud Tools**: AWS CLI v2
- **Text Editors**: Neovim, Micro, Nano
- **Shell**: Zsh with Oh My Zsh, Starship prompt

### Development Languages & Runtimes
- **Python 3**: pip, pipenv, poetry, common packages
- **Node.js**: npm, global development packages
- **Ruby**: rbenv with latest Ruby version
- **Go, Rust**: via Homebrew

### Development Tools
- **Terminal**: tmux, screen, modern Unix tools (bat, exa, fd, ripgrep, fzf)
- **Code Quality**: ESLint, Prettier, Black, Flake8, ShellCheck
- **Databases**: PostgreSQL client, MySQL client, Redis tools, SQLite3
- **Media**: ImageMagick, FFmpeg
- **Documentation**: Pandoc

### Productivity Features
- **Smart Aliases**: Git shortcuts, Docker commands, navigation helpers
- **Windows Integration**: Commands to open Explorer, VS Code from WSL
- **Auto-completion**: Enhanced shell experience with suggestions
- **Development Directories**: Pre-configured project structure

## 💻 Compatibility

- ✅ **WSL2** - Fully tested and optimized
- ✅ **Ubuntu 22.04 LTS & 24.04 LTS** - Primary support
- ✅ **Ubuntu 20.04 LTS** - Supported with minor limitations
- ✅ **systemd** - Utilized when available
- ✅ **Windows 11 & Windows 10** - Universal support

## 🔧 Prerequisites

1. **WSL2 enabled** on Windows 10/11
2. **Ubuntu distribution** installed via Microsoft Store or `wsl --install`
3. **Internet connection** for package downloads
4. **At least 2GB free disk space**

## 🛠 Alternative Usage

### Using Individual Scripts
```bash
# Setup only core tools
./setup/initial.sh

# Install development tools only
./setup/my_installs.sh

# Configure environment only
./setup/configure_linux.sh
```

### Manual Package Installation
```bash
# Install from package list
sudo apt update
cat packages.txt | grep -v '^#' | xargs sudo apt install -y
```

## 🔄 Maintenance

- **`update_tools.sh`** - Update all installed packages and tools
- **`backup.sh`** - Backup current configuration and package lists
- Run `sudo apt autoremove` to clean up unused packages

## 🎯 WSL-Specific Features

### Windows Integration
- **File System Access**: Windows drives mounted at `/mnt/c`, `/mnt/d`, etc.
- **Command Integration**: Run Windows executables from WSL
- **VS Code Integration**: Seamless development with WSL extension
- **Git Credential Sharing**: Use Windows Git credentials

### Performance Optimizations
- **systemd support**: Modern service management when available
- **Docker optimization**: Configured for WSL2 performance
- **Memory management**: Efficient resource usage
- **Network configuration**: Proper localhost forwarding

### Useful Commands Added
```bash
# Open current directory in Windows Explorer
open .

# Open VS Code in current directory
code-here .

# Navigate to Windows user home
winhome

# Quick access to Windows applications
explorer.exe
notepad.exe
```

## 📚 Additional Setup Recommendations

### VS Code Integration
1. Install VS Code on Windows
2. Install the "WSL" extension
3. Use `code .` from any WSL directory

### Git Configuration
```bash
# Set up your Git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "your.email@example.com"
```

### Windows Terminal
- Install Windows Terminal from Microsoft Store
- Configure Ubuntu as default profile for better experience

### .wslconfig Optimization
Create `C:\Users\YourUsername\.wslconfig`:
```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
```

## 🔍 Troubleshooting

### Common Issues
- **Permission errors**: Run scripts with proper permissions (`chmod +x script.sh`)
- **Network issues**: Check Windows firewall and antivirus settings
- **Docker problems**: Ensure WSL2 backend is enabled in Docker Desktop
- **Memory issues**: Adjust `.wslconfig` memory settings

### Getting Help
```bash
# Check compatibility
./check_compatibility.sh

# View system information
neofetch

# Check WSL version
wsl.exe -l -v
```

## 🚀 Ready to Code!

After running the bootstrap, you'll have a fully configured development environment with:
- Modern shell with auto-completion and syntax highlighting
- All major programming languages and tools
- Docker for containerization
- Cloud development tools
- Seamless Windows integration

Happy coding! 🎉

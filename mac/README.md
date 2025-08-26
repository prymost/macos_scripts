# macOS Setup Scripts

My pesonal scripts for setting up and maintaining a new MacBook with my preferred configuration.

## 🚀 Quick Start

1. **Run compatibility check** (recommended):
   ```bash
   ./check_compatibility.sh
   ```

2. **Run full bootstrap**:
   ```bash
   ./bootstrap.sh
   ```

## 📁 Script Overview

- **`bootstrap.sh`** - Main entry point that orchestrates the entire setup
- **`check_compatibility.sh`** - Validates system compatibility before setup
- **`setup/initial.sh`** - Installs Xcode tools, Homebrew, and core utilities
- **`setup/my_installs.sh`** - Generates Brewfile from common config and installs applications
- **`setup/configure_osx.sh`** - Configures macOS system preferences
- **`setup/restore.sh`** - Restores backed-up configuration files

## 💻 Compatibility

- ✅ **macOS 15.5 (Sequoia)** - Fully tested and compatible
- ✅ **Apple Silicon & Intel Macs** - Universal support
- ✅ **zsh shell** - Optimized for modern macOS default shell

## 🛠 Alternative Usage

### Using Generated Brewfile
```bash
# Run setup first to generate Brewfile, then:
brew bundle install
```

### Running Individual Scripts
```bash
# Setup only core tools
./setup/initial.sh

# Install applications only (generates Brewfile from common config)
./setup/my_installs.sh

# Configure system settings only
./setup/configure_osx.sh
```

## 🔄 Maintenance

- **`update_tools.sh`** - Update Homebrew packages and any generated Brewfile
- **`backup.sh`** - Backup current configuration
- Run `brew bundle cleanup` to remove unlisted packages (after generating Brewfile)

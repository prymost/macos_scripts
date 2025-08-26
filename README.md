# Bootstrap Scripts

Automated setup scripts for my personal machines

## Quick Start

```bash
# Windows (as Administrator)
PowerShell -ExecutionPolicy Bypass -File windows/bootstrap-windows11.ps1

# macOS
./mac/bootstrap.sh

# WSL/Linux
./windows/wsl_scripts/bootstrap.sh
```

## How It Works

- **Windows**: Reads `common/apps.json` using built-in PowerShell, falls back to hardcoded list
- **macOS**: Auto-installs `jq` if needed to parse `common/apps.json`, generates Brewfile dynamically
- **WSL Ubuntu**: Uses `jq` to extract WSL Ubuntu-specific packages from `common/apps.json`
- **All platforms**: Multiple fallback layers ensure scripts never fail

## Configuration

Edit `common/apps.json` to add/remove applications across all platforms. The bootstrap scripts read this automatically.

## Platform Details

- [mac/README.md](mac/README.md) - macOS specifics
- [windows/README.md](windows/README.md) - Windows 11 specifics
- [windows/wsl_scripts/README.md](windows/wsl_scripts/README.md) - WSL/Linux specifics
- [common/README.md](common/README.md) - Shared configuration

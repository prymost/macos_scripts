#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

echo "🔍 WSL Ubuntu Setup Compatibility Check"
echo "====================================="

# Get Linux distribution and version
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "🐧 Linux Distribution: $PRETTY_NAME"
    echo "📦 Version ID: $VERSION_ID"
else
    echo "⚠️  Could not determine Linux distribution"
fi

# Check if running in WSL
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    echo "✅ Running in WSL: $WSL_DISTRO_NAME"
    WSL_VERSION=$(wsl.exe -l -v 2>/dev/null | grep "$WSL_DISTRO_NAME" | awk '{print $3}' || echo "unknown")
    echo "📱 WSL Version: $WSL_VERSION"
else
    echo "⚠️  Not running in WSL environment"
fi

# Check Ubuntu version compatibility
if [[ -f /etc/os-release ]] && grep -q "ubuntu" /etc/os-release; then
    UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "unknown")
    echo "🎯 Ubuntu Version: $UBUNTU_VERSION"

    if [[ "$UBUNTU_VERSION" == "22.04" ]] || [[ "$UBUNTU_VERSION" == "24.04" ]]; then
        echo "✅ Ubuntu version is modern and fully supported"
    elif [[ "$UBUNTU_VERSION" == "20.04" ]]; then
        echo "✅ Ubuntu 20.04 is supported with some limitations"
    else
        echo "⚠️  Ubuntu version may have limited support"
    fi
else
    echo "⚠️  Non-Ubuntu distributions may require script modifications"
fi

# Check architecture
ARCH=$(uname -m)
echo "💻 Architecture: $ARCH"

if [[ $ARCH == "x86_64" ]]; then
    echo "✅ x64 architecture - fully supported"
elif [[ $ARCH == "aarch64" ]]; then
    echo "✅ ARM64 architecture - supported on ARM Windows"
else
    echo "⚠️  Unusual architecture - some packages may not be available"
fi

# Check if systemd is available (WSL2 feature)
if systemctl --version &>/dev/null; then
    echo "✅ systemd: Available"
else
    echo "⚠️  systemd: Not available (WSL1 or older WSL2)"
fi

# Check internet connectivity
if ping -c 1 google.com &> /dev/null; then
    echo "✅ Internet connectivity: Working"
else
    echo "⚠️  Internet connectivity: Issues detected"
fi

# Check if apt is working
if command -v apt &> /dev/null; then
    echo "✅ APT package manager: Available"

    # Check if we can update package lists
    if sudo apt update &> /dev/null; then
        echo "✅ Package repository access: Working"
    else
        echo "⚠️  Package repository access: Issues detected"
    fi
else
    echo "❌ APT package manager: Not available"
fi

# Check shell
CURRENT_SHELL=$(basename $SHELL)
echo "🐚 Current shell: $CURRENT_SHELL"

if [[ $CURRENT_SHELL == "bash" ]]; then
    echo "✅ Using bash (default for Ubuntu)"
elif [[ $CURRENT_SHELL == "zsh" ]]; then
    echo "✅ Using zsh (will be configured)"
else
    echo "⚠️  Using $CURRENT_SHELL - script will install zsh"
fi

# Check available disk space
AVAILABLE_SPACE=$(df -h / | awk 'NR==2 {print $4}')
echo "💾 Available disk space: $AVAILABLE_SPACE"

# Check memory
TOTAL_MEM=$(free -h | awk 'NR==2{print $2}')
echo "🧠 Total memory: $TOTAL_MEM"

# Check if Windows host is accessible
if [[ -d "/mnt/c" ]]; then
    echo "✅ Windows filesystem: Accessible at /mnt/c"
else
    echo "⚠️  Windows filesystem: Not mounted"
fi

echo ""
echo "🎯 Recommendations:"
echo "=================="

echo "✅ Ensure WSL2 is being used for better performance"
echo "💡 Before running bootstrap:"
echo "   - Ensure WSL has internet access"
echo "   - Have at least 2GB free disk space"
echo "   - Close unnecessary Windows applications"
echo "   - Run 'wsl --update' in Windows PowerShell to update WSL"

if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    echo "🔧 WSL-specific tips:"
    echo "   - Windows integration is available"
    echo "   - Use VS Code with WSL extension for development"
    echo "   - Git credentials can be shared with Windows"
fi

echo ""
echo "🚀 Ready to run bootstrap.sh!"

#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "🚀 Starting WSL Ubuntu bootstrap process..."
echo "📁 Script directory: $SCRIPT_DIR"

# Run compatibility check first
echo "🔍 Running compatibility check..."
"${SCRIPT_DIR}/check_compatibility.sh"

echo ""
read -p "Continue with bootstrap? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Bootstrap cancelled by user"
    exit 1
fi

echo "🔧 Running initial setup..."
"${SCRIPT_DIR}/setup/initial.sh"

echo "⚙️  Configuring Linux settings..."
"${SCRIPT_DIR}/setup/configure_linux.sh"

echo "📦 Installing applications and packages..."
"${SCRIPT_DIR}/setup/my_installs.sh"

echo "🔄 Updating package database..."
sudo apt update && sudo apt upgrade -y

echo "✅ Bootstrap process completed!"
echo ""
echo "🎨 Solarized Dark terminal theme setup:"
echo "   ✅ Oh My Zsh with agnoster theme configured"
echo "   ✅ MesloLGS NF font installed for powerline symbols"
echo "   ✅ Auto-suggestions and syntax highlighting enabled"
echo "   ✅ Git configuration optimized for WSL"
echo ""
echo "🔄 To complete the setup:"
echo "   1. Change default shell: chsh -s \$(which zsh)"
echo "   2. Restart WSL: wsl --shutdown (in Windows PowerShell)"
echo "   3. Launch Ubuntu from Windows Terminal"
echo "   4. Your beautiful Solarized Dark terminal is ready! 🎉"

# Uncomment the line below if you want to restore from backup
# "${SCRIPT_DIR}/setup/restore.sh"

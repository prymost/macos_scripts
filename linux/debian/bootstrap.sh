#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "🚀 Starting PopOS/Debian bootstrap process..."
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

echo "📦 Installing applications and packages..."
"${SCRIPT_DIR}/setup/my_installs.sh"

echo "✅ Bootstrap process completed!"
echo "🔄 Please restart your session to ensure all changes take effect."

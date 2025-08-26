#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

echo "📦 Installing development tools and applications..."

# Define package lists by category (only apps from apps.json)
CLI_TOOLS=(
    "git"
    "jq"
    "bat"
    "direnv"
    "micro"
    "awscli"
)

DEVELOPMENT_TOOLS=(
    "code"           # VS Code
    "docker.io"      # Docker
    "rbenv"
    "ruby-build"
    "pipenv"
    "zsh"
    "zsh-autosuggestions"
    "kubectl"
    "keychain"
)

OTHER=(
    "brave-browser"
    "vlc"
    "discord"
    "zoom"
    "steam"
    "synology-drive-client"
)

# Combine all packages
ALL_PACKAGES=(
    "${CLI_TOOLS[@]}"
    "${DEVELOPMENT_TOOLS[@]}"
    "${OTHER[@]}"
)

# Install packages
if [[ ${#ALL_PACKAGES[@]} -gt 0 ]]; then
    echo "📦 Installing ${#ALL_PACKAGES[@]} packages..."
    sudo apt update
    sudo apt install -y "${ALL_PACKAGES[@]}"
    echo "✅ Package installation completed!"
else
    echo "ℹ️  No packages to install"
fi

echo "🧹 Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

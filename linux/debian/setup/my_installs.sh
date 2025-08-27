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
    "docker.io"      # Docker
    "rbenv"
    "ruby-build"
    "pipenv"
    "zsh"
    "zsh-autosuggestions"
    "keychain"
)

OTHER=(
    "vlc"
    "discord"
    "steam-installer"
)

# Combine all packages that can be installed via apt
ALL_PACKAGES=(
    "${CLI_TOOLS[@]}"
    "${DEVELOPMENT_TOOLS[@]}"
    "${OTHER[@]}"
)

# Install standard packages
if [[ ${#ALL_PACKAGES[@]} -gt 0 ]]; then
    echo "📦 Installing ${#ALL_PACKAGES[@]} standard packages..."
    sudo apt update -qq
    sudo apt install -y -qq "${ALL_PACKAGES[@]}"
    echo "✅ Standard package installation completed!"
else
    echo "ℹ️  No standard packages to install"
fi

# Install special packages that need additional steps
echo "🔧 Installing packages that need special setup..."

# Install VS Code
echo "📦 Installing VS Code..."
if ! command -v code &> /dev/null; then
    # Add Microsoft GPG key and repository
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update -qq
    sudo apt install -y -qq code
    rm packages.microsoft.gpg
    echo "✅ VS Code installed"
else
    echo "✅ VS Code already installed"
fi

# Install Brave Browser
echo "📦 Installing Brave Browser..."
if ! command -v brave-browser &> /dev/null; then
    sudo apt install -y -qq apt-transport-https curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update -qq
    sudo apt install -y -qq brave-browser
    echo "✅ Brave Browser installed"
else
    echo "✅ Brave Browser already installed"
fi

# Install kubectl
echo "📦 Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "✅ kubectl installed"
else
    echo "✅ kubectl already installed"
fi

# Synology Drive Client
echo "📦 Installing Synology Drive Client..."
if ! dpkg -l | grep -q synology-drive-client; then
    # Create temp directory for download
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download the latest Synology Drive Client .deb file
    echo "🔄 Downloading Synology Drive Client..."
    SYNOLOGY_URL="https://global.download.synology.com/download/Utility/SynologyDriveClient/3.5.0-15724/Ubuntu/Installer/x86_64/synology-drive-client-15724.x86_64.deb"
    wget -q -O synology-drive-client.deb "$SYNOLOGY_URL"

    if [[ -f synology-drive-client.deb ]]; then
        echo "📦 Installing Synology Drive Client..."
        sudo dpkg -i synology-drive-client.deb
        # Fix any dependency issues
        sudo apt-get install -f -y -qq
        echo "✅ Synology Drive Client installed"
    else
        echo "❌ Failed to download Synology Drive Client"
        echo "⚠️  Please download manually from:"
        echo "    https://www.synology.com/en-us/support/download_center"
    fi

    # Clean up temp directory
    cd -
    rm -rf "$TEMP_DIR"
else
    echo "✅ Synology Drive Client already installed"
fi

# Install Logseq
echo "📦 Installing Logseq..."
if ! command -v logseq &> /dev/null; then
    # Create temp directory for download
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download Logseq .deb file (latest version)
    echo "🔄 Downloading Logseq..."
    LOGSEQ_URL="https://github.com/logseq/logseq/releases/latest/download/logseq-linux-x64.deb"
    wget -q -O logseq.deb "$LOGSEQ_URL"

    if [[ -f logseq.deb ]]; then
        echo "📦 Installing Logseq..."
        sudo dpkg -i logseq.deb
        # Fix any dependency issues
        sudo apt-get install -f -y -qq
        echo "✅ Logseq installed"
    else
        echo "❌ Failed to download Logseq"
        echo "⚠️  Please download manually from: https://github.com/logseq/logseq/releases"
    fi

    # Clean up temp directory
    cd -
    rm -rf "$TEMP_DIR"
else
    echo "✅ Logseq already installed"
fi

# Install Calibre
echo "📦 Installing Calibre..."
if ! command -v calibre &> /dev/null; then
    echo "🔄 Downloading and installing Calibre..."
    sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
    echo "✅ Calibre installed"
else
    echo "✅ Calibre already installed"
fi

echo "🧹 Cleaning up..."
sudo apt autoremove -y -qq
sudo apt autoclean -qq

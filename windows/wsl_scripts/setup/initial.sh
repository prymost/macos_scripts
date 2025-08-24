#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

echo "🔧 Running initial WSL setup..."

# Update package lists
echo "📦 Updating package lists..."
sudo apt update

# Install essential packages
echo "🛠️  Installing essential packages..."
sudo apt install -y \
    curl \
    git \
    build-essential \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    zip \
    nano

# Install Python 3 and pip
echo "🐍 Installing Python 3 and pip..."
sudo apt install -y python3 python3-pip python3-venv

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package lists and install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker $USER

    echo "⚠️  You'll need to restart your WSL session for Docker group membership to take effect"
else
    echo "✅ Docker already installed"
fi

# Install AWS CLI v2
# echo "☁️  Installing AWS CLI v2..."
# if ! command -v aws &> /dev/null; then
#     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#     unzip awscliv2.zip
#     sudo ./aws/install
#     rm -rf aws awscliv2.zip
# else
#     echo "✅ AWS CLI already installed"
# fi

# Install Zsh
echo "🐚 Installing Zsh..."
if ! command -v zsh &> /dev/null; then
    sudo apt install -y zsh

    chsh -s $(which zsh)
else
    echo "✅ Zsh already installed"
fi

# Clean up
echo "🧹 Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo "✅ Initial setup completed!"

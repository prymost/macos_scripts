#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

# Install Xcode Command Line Tools
echo "Installing Xcode Command Line Tools..."
xcode-select --install
sudo xcodebuild -license accept

# Homebrew
export SHELL_NAME=$(basename ${SHELL})
echo "Installing homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Already installed Homebrew"
fi

# Update homebrew recipes
brew update

# Install GNU core utilities (those that come with macOS are outdated)
# Note: homebrew/cask tap is no longer needed - casks are built into Homebrew core
brew install coreutils
brew install gnu-sed
brew install gnu-tar
brew install gnu-indent
brew install gnu-which
brew install gnu-grep

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

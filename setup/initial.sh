#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

xcode updates
xcode-select --install
sudo xcodebuild -license accept

# Homebrew
export SHELL_NAME=$(basename ${SHELL})
echo "Installing homebrew..."
if ! which brew 1>/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Already installed Homebrew"
fi

# Update homebrew recipes
brew update

# Install GNU core utilities (those that come with OS X are outdated)
brew tap homebrew/cask
brew install coreutils
brew install gnu-sed
brew install gnu-tar
brew install gnu-indent
brew install gnu-which
brew install gnu-grep

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BREWFILE_PATH="${SCRIPT_DIR}/Brewfile"

echo "🍺 ***** Homebrew Update *****"
echo "Updating Homebrew itself..."
brew update

echo "Upgrading all packages..."
brew upgrade

if [[ -f "$BREWFILE_PATH" ]]; then
    echo "Installing any new packages from Brewfile..."
    brew bundle install --file="$BREWFILE_PATH"

    echo "Cleaning up packages not in Brewfile..."
    brew bundle cleanup --file="$BREWFILE_PATH" --force
fi

echo "💎 ***** Ruby Gems Update *****"
if command -v rbenv &> /dev/null; then
    # Check if there's a global Ruby version set
    if rbenv global 2>/dev/null | grep -v "system" &> /dev/null; then
        RUBY_VERSION=$(rbenv global)
        echo "Updating gems for Ruby $RUBY_VERSION..."
        gem update --system
        gem update
    else
        echo "No global Ruby version set via rbenv, skipping gem updates"
    fi
elif command -v ruby &> /dev/null; then
    echo "Using system Ruby, updating gems..."
    gem update --system
    gem update
else
    echo "Ruby not found, skipping gem updates"
fi

echo "🐍 ***** Python Packages Update *****"
if command -v python3 &> /dev/null; then
    echo "Updating pip..."
    python3 -m pip install --upgrade pip

    # Update global packages if any are installed
    if python3 -m pip list --user 2>/dev/null | grep -q .; then
        echo "Updating user-installed Python packages..."
        python3 -m pip list --user --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install --user -U
    else
        echo "No user-installed Python packages found"
    fi
else
    echo "Python3 not found, skipping pip updates"
fi

echo "📦 ***** NPM Packages Update *****"
if command -v npm &> /dev/null; then
    echo "Updating npm itself..."
    npm install -g npm@latest

    # Check if there are global packages installed
    if npm list -g --depth=0 2>/dev/null | grep -q .; then
        echo "Updating global npm packages..."
        npm update -g
    else
        echo "No global npm packages found"
    fi
else
    echo "npm not found, skipping npm updates"
fi

echo "🧹 ***** Cleanup *****"
brew cleanup
echo "✅ All updates completed!"

#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

# Install packages and applications using Brewfile
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BREWFILE_PATH="${SCRIPT_DIR}/../Brewfile"
COMMON_CONFIG_PATH="${SCRIPT_DIR}/../../common/apps.json"

echo "📦 Installing packages and applications..."

# Generate Brewfile from common config if available and jq is installed
if [[ -f "$COMMON_CONFIG_PATH" ]] && command -v jq &> /dev/null; then
    echo "🔧 Generating Brewfile from common configuration..."

    # Backup existing Brewfile if it exists
    if [[ -f "$BREWFILE_PATH" ]]; then
        cp "$BREWFILE_PATH" "${BREWFILE_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "📋 Backed up existing Brewfile"
    fi

    # Generate new Brewfile
    cat > "$BREWFILE_PATH" << 'EOF'
# Brewfile for macOS Setup - Generated from common/apps.json
# Install with: brew bundle install

EOF

    # Add CLI Tools
    echo "# CLI Tools" >> "$BREWFILE_PATH"
    jq -r '.categories.cli_tools.apps | to_entries[] | select(.value.macos != null) | "brew \"\(.value.macos)\""' "$COMMON_CONFIG_PATH" >> "$BREWFILE_PATH"

    # Add Programming Languages
    echo "" >> "$BREWFILE_PATH"
    echo "# Programming Languages" >> "$BREWFILE_PATH"
    jq -r '.categories.languages.apps | to_entries[] | select(.value.macos != null) | "brew \"\(.value.macos)\""' "$COMMON_CONFIG_PATH" >> "$BREWFILE_PATH"

    # Add Terminal Tools
    echo "" >> "$BREWFILE_PATH"
    echo "# Terminal Tools" >> "$BREWFILE_PATH"
    jq -r '.categories.terminal.apps | to_entries[] | select(.value.macos != null and .key != "iterm2") | "brew \"\(.value.macos)\""' "$COMMON_CONFIG_PATH" >> "$BREWFILE_PATH"

    # Add Desktop Applications (casks)
    echo "" >> "$BREWFILE_PATH"
    echo "# Desktop Applications" >> "$BREWFILE_PATH"
    for category in browsers development productivity media communication cloud_sync; do
        jq -r ".categories.${category}.apps | to_entries[] | select(.value.macos != null) | \"cask \\\"\(.value.macos)\\\"\"" "$COMMON_CONFIG_PATH" >> "$BREWFILE_PATH"
    done

    # Add terminal applications as casks
    jq -r '.categories.terminal.apps | to_entries[] | select(.value.macos != null and .key == "iterm2") | "cask \"\(.value.macos)\""' "$COMMON_CONFIG_PATH" >> "$BREWFILE_PATH"

    # Add macOS-specific apps
    echo "" >> "$BREWFILE_PATH"
    echo "# macOS-specific" >> "$BREWFILE_PATH"
    jq -r '.platform_specific.macos_only[]? | "brew \"\(.)\""' "$COMMON_CONFIG_PATH" >> "$BREWFILE_PATH"

    echo "✅ Generated Brewfile from common configuration"
elif [[ -f "$COMMON_CONFIG_PATH" ]] && ! command -v jq &> /dev/null; then
    echo "⚠️  Common configuration found but jq not available"
    echo "📋 Using existing Brewfile or installing jq first..."

    # Install jq first if Brewfile doesn't exist
    if [[ ! -f "$BREWFILE_PATH" ]]; then
        echo "📦 Installing jq to generate Brewfile..."
        brew install jq
        # Recursively call this script to regenerate
        exec "$0"
    fi
else
    echo "📋 Using existing Brewfile..."
fi

# Install from Brewfile
if [[ -f "$BREWFILE_PATH" ]]; then
    echo "📦 Installing packages from Brewfile..."
    brew bundle install --file="${BREWFILE_PATH}"
else
    echo "❌ No Brewfile found. Creating minimal fallback..."
    # Fallback installation
    brew install git jq rbenv python@3.13 zsh zsh-autosuggestions
    brew install --cask visual-studio-code iterm2 brave-browser
fi

# Ruby Setup
rbenv init
# Verify that rbenv is properly set up using this rbenv-doctor script
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Zrefresh
# source ~/.zshrc

echo "Cleaning up..."
brew cleanup

# TWEAK SOME APP SETTINGS

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Use VSCode to edit git prompts
git config --global push.autoSetupRemote true
git config --global push.default current
git config --global core.editor "code -n -w"
git config --global remote.origin.prune true

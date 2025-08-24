#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

# Install packages and applications using package lists
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "📦 Installing development tools and applications..."

# APT packages
echo "📋 Installing APT packages..."
sudo apt update

# Development tools
sudo apt install -y \
    jq \
    bat \
    direnv \
    micro \
    keychain \
    kubectl

# Language-specific tools
echo "🔧 Installing language-specific tools..."

# Ruby with rbenv
echo "💎 Installing Ruby with rbenv..."
if ! command -v rbenv &> /dev/null; then
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"

    # Install latest Ruby
    LATEST_RUBY=$(rbenv install -l | grep -v - | tail -1 | tr -d ' ')
    rbenv install $LATEST_RUBY
    rbenv global $LATEST_RUBY
else
    echo "✅ rbenv already installed"
fi

# Python tools
echo "🐍 Installing Python development tools..."
pip3 install --user \
    pipenv \
    flake8 \
    pytest

# Install Nerd Font for powerline symbols
echo "🔤 Installing Nerd Font..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Download MesloLGS NF font (required for proper agnoster theme display)
if [[ ! -f "MesloLGS NF Regular.ttf" ]]; then
    curl -fLo "MesloLGS NF Regular.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    curl -fLo "MesloLGS NF Bold.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    curl -fLo "MesloLGS NF Italic.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    curl -fLo "MesloLGS NF Bold Italic.ttf" \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

    # Update font cache
    fc-cache -fv
    echo "✅ MesloLGS NF font installed"
else
    echo "✅ MesloLGS NF font already installed"
fi

cd "$SCRIPT_DIR"

# Oh My Zsh setup for Solarized Dark terminal
if command -v zsh &> /dev/null; then
    echo "🐚 Setting up Oh My Zsh with agnoster theme..."
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # Install essential plugins for better terminal experience
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

        # Configure .zshrc with agnoster theme (similar to article setup)
        echo "🎨 Configuring Zsh with agnoster theme for Solarized Dark..."
        sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker python pip ruby rbenv)/' ~/.zshrc
        # Add agnoster theme configuration for clean prompt
        echo "" >> ~/.zshrc
        echo "# Solarized Dark terminal configuration" >> ~/.zshrc
        echo "DEFAULT_USER=\"\$USER\"" >> ~/.zshrc
        echo "# Hide user@hostname for cleaner prompt" >> ~/.zshrc
        echo "prompt_context() {" >> ~/.zshrc
        echo "  if [[ \"\$USER\" != \"\$DEFAULT_USER\" || -n \"\$SSH_CLIENT\" ]]; then" >> ~/.zshrc
        echo "    prompt_segment black default \"%(!.%{%F{yellow}%}.)%n@%m\"" >> ~/.zshrc
        echo "  fi" >> ~/.zshrc
        echo "}" >> ~/.zshrc
        # Add some useful Oh My Zsh configurations
        echo "" >> ~/.zshrc
        echo "# Oh My Zsh configuration improvements" >> ~/.zshrc
        echo "DISABLE_UPDATE_PROMPT=true" >> ~/.zshrc
        echo "COMPLETION_WAITING_DOTS=true" >> ~/.zshrc
        echo "HIST_STAMPS=\"yyyy-mm-dd\"" >> ~/.zshrc

        # Configure agnoster theme settings
        echo "" >> ~/.zshrc
        echo "# Agnoster theme configuration" >> ~/.zshrc
        echo "DEFAULT_USER=\"\$USER\"" >> ~/.zshrc
        echo "prompt_context() {}" >> ~/.zshrc  # Hide user@hostname if it's your default user

    else
        echo "✅ Oh My Zsh already installed"
        # Still update the theme if it's not agnoster
        if ! grep -q 'ZSH_THEME="agnoster"' ~/.zshrc; then
            echo "🎨 Updating theme to agnoster..."
            sed -i 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc
        fi
    fi
fi

# Set up git configuration for common workflows
echo "🔧 Setting up Git configuration..."
# Configure Git to handle line endings properly in WSL
git config --global core.autocrlf input
git config --global core.eol lf

echo "🧹 Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo "✅ Solarized Dark terminal setup completed!"
echo ""
echo "🎉 Next steps:"
echo "   1. Restart WSL: wsl --shutdown (in Windows PowerShell)"
echo "   2. Change default shell to zsh: chsh -s \$(which zsh)"
echo "   3. Restart your terminal to see Solarized Dark theme with agnoster prompt"
echo "   4. Configure Git credentials if needed"

#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

echo "⚙️  Configuring Linux settings..."

# Configure Git (basic setup)
echo "🔧 Configuring Git..."
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global push.default current
git config --global remote.origin.prune true
git config --global pull.rebase false

# If code command is available (VS Code), set it as git editor
if command -v code &> /dev/null; then
    git config --global core.editor "code --wait"
    echo "✅ Set VS Code as Git editor"
else
    git config --global core.editor "nano"
    echo "✅ Set nano as Git editor"
fi

# Configure shell aliases
echo "🔧 Setting up shell aliases..."
ALIASES_FILE="$HOME/.bash_aliases"

cat > "$ALIASES_FILE" << 'EOF'
# Navigation
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Docker shortcuts
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'

# System info
alias df='df -h'
alias du='du -h'
alias free='free -h'

# WSL specific
alias winhome='cd /mnt/c/Users/$USER'
alias explorer='explorer.exe'
alias notepad='notepad.exe'

# Development
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'
alias venv='python3 -m venv'

# Productivity
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias cls='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
EOF

# Source aliases in bashrc if not already done
if ! grep -q "bash_aliases" ~/.bashrc; then
    echo "# Load custom aliases" >> ~/.bashrc
    echo "if [ -f ~/.bash_aliases ]; then" >> ~/.bashrc
    echo "    . ~/.bash_aliases" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
fi

# Configure WSL-specific settings
echo "🔧 Configuring WSL-specific settings..."

# Create/update .wslconfig for the user (this goes in Windows user directory)
# Note: This is informational - user needs to create this in Windows
echo "💡 WSL Configuration recommendations:"
echo "    Create/update C:\\Users\\YOUR_USERNAME\\.wslconfig with:"
echo "    [wsl2]"
echo "    memory=8GB"
echo "    processors=4"
echo "    swap=2GB"
echo "    localhostForwarding=true"

# Configure umask for better file permissions
echo "🔧 Setting up file permissions..."
if ! grep -q "umask 022" ~/.bashrc; then
    echo "umask 022" >> ~/.bashrc
fi

# Configure Python defaults
# echo "🐍 Configuring Python environment..."
# Create pip config directory
# mkdir -p ~/.config/pip

# Configure pip to use user directory by default
# cat > ~/.config/pip/pip.conf << 'EOF'
# [install]
# user = true

# [list]
# format = columns
# EOF

# Add user's local bin to PATH if not already there
if ! grep -q '$HOME/.local/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Configure Docker to start on WSL startup (if systemd is available)
if systemctl --version &>/dev/null; then
    echo "🐳 Enabling Docker service..."
    sudo systemctl enable docker
else
    echo "💡 systemd not available. Start Docker manually with: sudo service docker start"
fi

# Set up development-friendly settings
echo "🛠️  Setting up development environment..."

# Set up SSH directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh
# touch ~/.ssh/authorized_keys
# chmod 600 ~/.ssh/authorized_keys

echo "✅ Linux configuration completed!"
echo ""
echo "🔄 To apply all changes, run: source ~/.bashrc"
echo "💡 Or restart your WSL session"

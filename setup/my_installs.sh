#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

# Brew packages
BREW_PACKS=(
  awscli
  bash
  bat
  direnv
  git
  jq
  micro
  pipenv
  python
  python3
  zsh
  zsh-autosuggestions
)
echo "Installing packages..."
brew install ${BREW_PACKS[@]}

# Ruby Setup
brew install rbenv ruby-build
rbenv init
# Verify that rbenv is properly set up using this rbenv-doctor script
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash
# For M1 Mac ruby installs, need to specify openssl directory
# RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/homebrew/opt/openssl@1.1" rbenv install 2.6.10

# use zsh by default
# chsh -s /usr/local/bin/zsh

# Oh My Zsh
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Zrefresh
# source ~/.zshrc

echo "Cleaning up..."
brew cleanup

CASKS=(
  brave-browser
  docker
#  google-chrome
  iterm2
  notion
  sourcetree
  rectangle
  visual-studio-code
)
# Desktop apps
echo "Installing cask apps..."
brew install --cask ${CASKS[@]}

# TWEAK SOME APP SETTINGS

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Use VSCode to edit git prompts
git config --global push.autoSetupRemote true
git config --global push.default current
git config --global core.editor "code -n -w"
git config --global remote.origin.prune true

# NPM packager
# echo "Installing cask apps..."
# NPM_GLOBAL_PACKS=(
#   typescript
#   ts-node
# )
# npm i -g ${NPM_GLOBAL_PACKS[@]}

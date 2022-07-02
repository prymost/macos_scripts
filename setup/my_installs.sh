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

# use zsh by default
# chsh -s /usr/local/bin/zsh

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Zrefresh
source ~/.zshrc

echo "Cleaning up..."
brew cleanup

CASKS=(
  brave-browser
  docker
  google-chrome
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
git config --global core.editor "code --wait"

# NPM packager
# echo "Installing cask apps..."
# NPM_GLOBAL_PACKS=(
#   typescript 
#   ts-node 
# )
# npm i -g ${NPM_GLOBAL_PACKS[@]}

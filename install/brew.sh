#!/usr/bin/env bash

# Install Homebrew or make sure it's up to date
which -s brew
if [[ $? != 0 ]] ; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  brew update
  brew upgrade
fi

# Install packages

apps=(
  coreutils
  curl
  eza
  fd
  fzf
  git
  hledger
  make
  mise
  neovim
  pre-commit
  ripgrep
  rsync
  supabase/tap/supabase
  uv
  zoxide
)

brew install "${apps[@]}"

# Cleanup
brew cleanup

# Link applications

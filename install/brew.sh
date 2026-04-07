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
  bun
  coreutils
  curl
  eza
  fd
  fzf
  git
  hledger
  imagemagick
  make
  neovim
  node
  pre-commit
  ripgrep
  rsync
  supabase/tap/supabase
  tmux
  typst
  uv
  zoxide
)

brew install "${apps[@]}"

# Cleanup
brew cleanup

# Link applications

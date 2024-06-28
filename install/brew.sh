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
  curl
  fd
  git
  make
  neovim
  node
  pre-commit
  rg
  rust
  supabase/tap/supabase
  uv
)

brew install "${apps[@]}"

# Cleanup
brew cleanup

# Link applications

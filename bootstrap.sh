#!/usr/bin/env bash

# Get current dir (so can run this script from anywhere)
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES_DIR

# symlinks
ln -sfv "$DOTFILES_DIR/startup/.bash_profile" ~

# Package Managers and packages
. "$DOTFILES_DIR/install/brew.sh"
. "$DOTFILES_DIR/install/gem.sh"
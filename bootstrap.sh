#!/usr/bin/env bash

# Get current dir (so can run this script from anywhere)
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES_DIR

# Package Managers and packages
. "$DOTFILES_DIR/install/brew.sh"
. "$DOTFILES_DIR/install/cask.sh"
. "$DOTFILES_DIR/install/gem.sh"
. "$DOTFILES_DIR/install/pip.sh"

# symlinks
# ln -sfv "$DOTFILES_DIR/startup/.bash_profile" ~
ln -sfv "$DOTFILES_DIR/startup/.zshrc" ~
ln -sfv "$DOTFILES_DIR/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/git/.gitignore" ~

ln -sfv "$DOTFILES_DIR/system/pure.zsh" /usr/local/share/zsh/site-functions/prompt_pure_setup
ln -sfv "$DOTFILES_DIR/system/async.zsh" /usr/local/share/zsh/site-functions/async

# Make zsh default shell
sudo chsh -s /bin/zsh
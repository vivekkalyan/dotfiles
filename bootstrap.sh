#!/usr/bin/env bash

# Get current dir (so can run this script from anywhere)
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# OS
if [ "$(uname -s)" = "Darwin" ]; then
    OS="macOS"
else
    OS=$(uname -s)
fi

# Package Managers and packages
if [[ "$OS" = "macOS" ]]; then
    . "$DOTFILES_DIR/install/brew.sh"
    . "$DOTFILES_DIR/install/cask.sh"
else
    . "$DOTFILES_DIR/install/apt.sh"
fi

. "$DOTFILES_DIR/install/pip.sh"

# symlinks
# ln -sfv "$DOTFILES_DIR/startup/.bash_profile" ~
ln -sfv "$DOTFILES_DIR/startup/.zshrc" ~
ln -sfv "$DOTFILES_DIR/startup/.vimrc" ~

ln -sfv "$DOTFILES_DIR/git/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/git/.gitignore" ~
ln -sfv "$DOTFILES_DIR/git/.gitattributes" ~

ln -sfv "$DOTFILES_DIR/karabiner" ~/.config

ln -sfv "$DOTFILES_DIR/system/prompt.zsh" /usr/local/share/zsh/site-functions/prompt_pure_setup
ln -sfv "$DOTFILES_DIR/system/async.zsh" /usr/local/share/zsh/site-functions/async

sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells' && \
chsh -s $(brew --prefix)/bin/zsh

# Hosts file(
sudo wget https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts -O /etc/hosts
if [[ "$OS" = "macOS" ]]; then
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
else
    sudo /etc/rc.d/init.d/nscd restart
    
export OS DOTFILES_DIR

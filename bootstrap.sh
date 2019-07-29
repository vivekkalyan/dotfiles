#!/usr/bin/env bash

if ! [ $(id -u) = 0 ]; then
    echo "This script needs to be run as root." >&2
    exit 1
fi


if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
    USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
else
    real_user=$(whoami)
fi

# Get current dir (so can run this script from anywhere)
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# OS
if [ "$(uname -s)" = "Darwin" ]; then
    OS="macOS"
elif uname -r | grep -q ARCH; then
    OS="Arch"
else
    OS=$(uname -s)
fi

echo $OS

if [[ "$OS" = "Arch" ]]; then
    ln -sfv "$DOTFILES_DIR/arch/pacman.conf" "/etc/pacman.conf"
fi

# Package Managers and packages
if [[ "$OS" = "macOS" ]]; then
    . "$DOTFILES_DIR/install/brew.sh"
    . "$DOTFILES_DIR/install/cask.sh"
elif [[ "$OS" = "Arch" ]]; then
    echo "todo"
    #. "$DOTFILES_DIR/install/pacman.sh"
else
    . "$DOTFILES_DIR/install/apt.sh"
fi

. "$DOTFILES_DIR/install/pip.sh"

# symlinks
# ln -sfv "$DOTFILES_DIR/startup/.bash_profile" ~
sudo -u $real_user ln -sfv "$DOTFILES_DIR/startup/zshrc" "$USER_HOME/.zshrc"
sudo -u $real_user ln -sfv "$DOTFILES_DIR/startup/vimrc" "$USER_HOME/.vimrc"
sudo -u $real_user ln -sfv "$DOTFILES_DIR/startup/tmux.conf" "$USER_HOME/.tmux.conf"
sudo -u $real_user ln -sfv "$DOTFILES_DIR/startup/ctags" "$USER_HOME/.ctags"

sudo -u $real_user ln -sfv "$DOTFILES_DIR/git/gitconfig" "$USER_HOME/.gitconfig"
sudo -u $real_user ln -sfv "$DOTFILES_DIR/git/gitignore" "$USER_HOME/.gitignore"
sudo -u $real_user ln -sfv "$DOTFILES_DIR/git/gitattributes" "$USER_HOME/.gitattributes"

if [[ "$OS" = "macOS" ]]; then
    sudo -u $real_user ln -sfv "$DOTFILES_DIR/karabiner" $USER_HOME/.config
fi

sudo -u $real_user ln -sfv "$DOTFILES_DIR/system/prompt.zsh" /usr/local/share/zsh/site-functions/prompt_pure_setup
sudo -u $real_user ln -sfv "$DOTFILES_DIR/system/async.zsh" /usr/local/share/zsh/site-functions/async

sudo -u $real_user ln -sfv "$DOTFILES_DIR/vim" $USER_HOME/.vim

if [[ "$OS" = "macOS" ]]; then
    sudo sh -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells' && \
    chsh -s $(brew --prefix)/bin/zsh
fi

#audio
if [[ "$OS" = "Arch" ]]; then
    ln -sfv "$DOTFILES_DIR/arch/xinitrc" /etc/X11/xinit/xinitrc
    ln -sfv "$DOTFILES_DIR/arch/pulseaudio.conf" /etc/pulse/default.pa
    ln -sfv "$DOTFILES_DIR/arch/daemon.conf" /etc/pulse/daemon.conf
    sudo -u $real_user pulseaudio -k
    sudo -u $real_user pulseaudio --start
    ln -sfv "$DOTFILES_DIR/arch/50-mouse-acceleration.conf" /etc/X11/xorg.conf.d/50-mouse-acceleration.conf
fi

export OS DOTFILES_DIR

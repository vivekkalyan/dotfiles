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
  bat
  coreutils
  ctags
  fasd
  fd
  ffmpeg
  fzf
  gifsicle
  git
  gnu-sed --with-default-names
  grep --with-default-names
  imagemagick
  mobile-shell
  mosh
  mysql
  npm
  p7zip
  pandoc
  postgresql
  python
  ripgrep
  sqlite
  tldr
  tomcat
  vim
  wget
  wireshark --with-qt
  zsh
  zsh-completions
)

brew install "${apps[@]}"

# Cleanup
brew cleanup

# Link applications
ln -sfv /usr/local/opt/postgresql/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
ln -sfv /usr/local/opt/mysql/homebrew.mxcl.mysql.plist ~/Library/LaunchAgents/

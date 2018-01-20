#!/usr/bin/env bash

apps=(
  cheatsheet
  dropbox
  firefox
  flux
  iterm2
  karabiner-elements
  macdown
  postman
  spotifree
  spotify
  sublime-text
  telegram
  transmission
  vlc
)

brew cask install "${apps[@]}"

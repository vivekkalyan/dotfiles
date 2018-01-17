#!/usr/bin/env bash

apps=(
  cheatsheet
  firefox
  flux
  karabiner-elements
  iterm2
  sublime-text
  transmission
  vlc
)

brew cask install "${apps[@]}"

#!/usr/bin/env bash

apps=(
  alacritty
  bruno
  docker
  flux
  font-meslo-lg-nerd-font
  ghostty
  karabiner-elements
  linear-linear
  notion
  obsidian
  spotify
  telegram
)

brew cask install "${apps[@]}"

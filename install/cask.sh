#!/usr/bin/env bash

apps=(
  alacritty
  docker
  flux
  font-meslo-lg-nerd-font
  karabiner-elements
  linear-linear
  obsidian
  spotify
)

brew cask install "${apps[@]}"

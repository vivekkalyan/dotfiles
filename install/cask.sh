#!/usr/bin/env bash

apps=(
  claude
  docker
  flux
  font-meslo-lg-nerd-font
  ghostty
  karabiner-elements
  keepassxc
  linear-linear
  macwhisper
  msty
  notion
  obsidian
  raycast
  slack
  spotify
  telegram
  todoist
  vlc
  zen
  zoom
)

brew install --cask "${apps[@]}"

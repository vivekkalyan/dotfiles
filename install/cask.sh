#!/usr/bin/env bash

apps=(
  alacritty # can remove if ghostty works well
  bruno
  claude
  cursor
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
  orion
  raycast
  spotify
  telegram
  todoist
  vlc
  zoom
)

brew cask install "${apps[@]}"

#!/usr/bin/env bash

apps=(
  alacritty # can remove if ghostty works well
  bruno
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
  raycast
  spotify
  telegram
  todoist
  vlc
  zoom
)

brew cask install "${apps[@]}"

#!/usr/bin/env bash

apps=(
  alacritty
  docker
  flux
  karabiner-elements
  obsidian
  spotify
)

brew cask install "${apps[@]}"

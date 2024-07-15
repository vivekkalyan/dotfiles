#!/usr/bin/env bash

apps=(
  alacritty
  docker
  flux
  karabiner-elements
  linear-linear
  obsidian
  spotify
)

brew cask install "${apps[@]}"

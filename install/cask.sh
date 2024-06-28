#!/usr/bin/env bash

apps=(
  alacritty
  karabiner-elements
  spotify
  docker
)

brew cask install "${apps[@]}"

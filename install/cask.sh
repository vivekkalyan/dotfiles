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

quicklook=(
    betterzipql
    qlcolorcode
    qlimagesize
    qlmarkdown
    qlstephen
    qlvideo
    quicklook-csv
    quicklook-json
)

brew cask install "${apps[@]}"

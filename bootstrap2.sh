#!/bin/zsh
# COLOR
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No COLOR

clear
echo "Enter root password"

# Ask for the administrator password upfront.
sudo -v

# Keep Sudo until script is finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Update macOS
echo
echo "${GREEN}Looking for updates.."
echo
sudo softwareupdate -i -a

# Install Homebrew
if ! command -v brew &> /dev/null
then
  echo
  echo "${GREEN}Installing Homebrew"
  echo
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Append Homebrew initialization to .zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>${HOME}/.zprofile
  # Immediately evaluate the Homebrew environment settings for the current session
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "${GREEN}Homebrew installed"
fi


# Check installation and update
echo
echo "${GREEN}Checking homebrew installation"
echo
brew update && brew doctor

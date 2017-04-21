# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# OS
if [ "$(uname -s)" = "Darwin" ]; then
  OS="macOS"
else
  OS=$(uname -s)
fi

# Resolve DOTFILES_DIR (assuming ~/.dotfiles on distros without readlink and/or $BASH_SOURCE/$0)
READLINK=$(which greadlink || which readlink)
CURRENT_SCRIPT=$BASH_SOURCE

if [[ -n $CURRENT_SCRIPT && -x "$READLINK" ]]; then
  SCRIPT_PATH=$($READLINK -f "$CURRENT_SCRIPT")
  DOTFILES_DIR=$(dirname "$(dirname "$SCRIPT_PATH")")
elif [ -d "$HOME/personal/dotfiles" ]; then
  DOTFILES_DIR="$HOME/personal/dotfiles"
else
  echo "Unable to find dotfiles, exiting."
  return # `exit 1` would quit the shell itself
fi

# Load the shell dotfiles, and then some:
for DOTFILE in "$DOTFILES_DIR"/system/.{path,alias,prompt,rvm,functions}; do
  [ -r "$DOTFILE" ] && source "$DOTFILE"
done

# Set LSCOLORS
eval "$(gdircolors "$DOTFILES_DIR"/system/.dir_colors)"

# Settings for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/personal
source /usr/local/bin/virtualenvwrapper.sh


# Clean up
unset READLINK CURRENT_SCRIPT SCRIPT_PATH DOTFILE

# Export
export OS DOTFILES_DIR
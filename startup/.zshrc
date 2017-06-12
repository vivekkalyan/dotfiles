autoload -Uz compinit
compinit

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# OS
if [ "$(uname -s)" = "Darwin" ]; then
  OS="macOS"
else
  OS=$(uname -s)
fi

DOTFILES_DIR="$HOME/personal/dotfiles"

# Load the shell dotfiles, and then some:
for DOTFILE in "$DOTFILES_DIR"/system/.{path,alias,rvm,functions}; do
  echo $DOTFILE
  [ -r "$DOTFILE" ] && source "$DOTFILE"
done

for DOTFILE in "$DOTFILES_DIR"/system/{async,prompt,fasd}.zsh; do
  echo $DOTFILE
  [ -r "$DOTFILE" ] && source "$DOTFILE"
done

# Set LSCOLORS
eval "$(gdircolors "$DOTFILES_DIR"/system/.dir_colors)"

# Settings for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/personal
source /usr/local/bin/virtualenvwrapper.sh

# Clean up
unset DOTFILE

# Export
export OS DOTFILES_DIR
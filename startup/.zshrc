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

# Get dotfiles directory
SOURCE=${(%):-%N}
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

DOTFILES_DIR="$( cd -P "$( dirname "$( dirname "$SOURCE" )" )" && pwd )"


# Load the shell dotfiles, and then some:
for DOTFILE in "$DOTFILES_DIR"/system/.{path,alias,rvm,functions}; do
  [ -r "$DOTFILE" ] && source "$DOTFILE"
done

for DOTFILE in "$DOTFILES_DIR"/system/{async,prompt,fasd,fzf}.zsh; do
  [ -r "$DOTFILE" ] && source "$DOTFILE"
done

# Set LSCOLORS
if [[ "$OS" = "macOS" ]]; then
  dircolors="gdircolors"
else
  dircolors="dircolors"
fi
eval "$("$dircolors" "$DOTFILES_DIR"/system/.dir_colors)"

# Set base16-shell colors
source "$DOTFILES_DIR"/system/base16-tomorrow-night.sh

# Settings for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/personal
source /usr/local/bin/virtualenvwrapper.sh

# Clean up
unset DOTFILE

# Export
export OS DOTFILES_DIR

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

set -o vi

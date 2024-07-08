autoload -Uz compinit
compinit

# Infinite history.
HISTSIZE=1000000000
SAVEHIST=1000000000
HISTFILESIZE=1000000000
HISTFILE="$HOME/.zsh_history"

# History options
setopt hist_expire_dups_first  # if history needs to be trimmed, evict dups first
setopt hist_ignore_dups        # don't add consecutive dups to history
setopt hist_ignore_space       # don't add commands starting with space to history
setopt hist_reduce_blanks      # remove junk whitespace from commands before adding to history
setopt hist_verify             # if a cmd triggers history expansion, show it instead of running
setopt share_history           # share command history data
setopt extended_history        # write timestamps to history

# Set LSCOLORS
eval "$("dircolors" "$DOTFILES_DIR"/system/dircolors)"

# Colorize completions using default `ls` colors.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

bindkey -e # emacs bindings

# OS
if [ "$(uname -s)" = "Darwin" ]; then
  OS="macOS"
else
  OS=$(uname -s)
fi

# Get the .zshrc file path (~/.config/zsh/.zshrc)
SOURCE=${(%):-%N}
# Get the config dir (~/.config)
CONFIG_DIR="$( dirname $( dirname $SOURCE ) )"
# Get the real path of config dir (resolve symlinks)
DOTFILES_CONFIG_DIR="$(readlink -f $CONFIG_DIR)"
# Get the dotfiles directory (parent folder)
DOTFILES_DIR="$(dirname $DOTFILES_CONFIG_DIR)"

# Load the shell dotfiles, and then some:
for DOTFILE in "$DOTFILES_DIR"/system/{path,alias,rvm,functions}; do
  [ -r "$DOTFILE" ] && source "$DOTFILE"
done

for DOTFILE in "$DOTFILES_DIR"/system/{async,prompt,fasd,fzf,history}.zsh; do
  [ -r "$DOTFILE" ] && source "$DOTFILE"
done

# Set base16-shell colors
# source "$DOTFILES_DIR"/system/base16-tomorrow-night.sh

# Default Editor
export EDITOR=$(which nvim)
export VISUAL=$(which nvim)

# Vim to edit commands
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Fix ctrl+arrows
# https://hellricer.github.io/2019/05/21/ctrl-arrows-in-terminal.html
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

# ctrl+up/down for partial search
bindkey '^[[1;5A' history-substring-search-up
bindkey '^[[1;5B' history-substring-search-down
bindkey '^K' history-substring-search-up
bindkey '^J' history-substring-search-down

# Make CTRL-Z background things and unbackground them.
function fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
  else
    zle push-input
  fi
}
zle -N fg-bg
bindkey '^Z' fg-bg

globalias() {
    if [[ $LBUFFER =~ '[A-Z0-9]+$' ]]; then
        zle _expand_alias
        zle expand-word
    fi
    zle self-insert
}
zle -N globalias
bindkey " " globalias # space key to expand globalalias

# fzf completions
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# hledger
LEDGER_FILE=$HOME/personal/finance/2022.journal
export LEDGER_FILE

# config
XDG_CONFIG_HOME=$HOME/.config/
XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME XDG_DATA_HOME

# python
PYTHON=/usr/bin/python

# Settings for virtualenvwrapper
# export WORKON_HOME=$HOME/.virtualenvs
# export PROJECT_HOME=$HOME/personal
# source /usr/local/bin/virtualenvwrapper.sh

# Clean up
unset DOTFILE

# Export
export OS DOTFILES_DIR

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

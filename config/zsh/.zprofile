#eval "$(/opt/homebrew/bin/brew shellenv)"

# OS
if [ "$(uname -s)" = "Darwin" ]; then
  export OS="macOS"
else
  export OS=$(uname -s)
fi

# Get the .zshrc file path (~/.config/zsh/.zshrc)
SOURCE=${(%):-%N}
# Get the config dir (~/.config)
CONFIG_DIR="$( dirname $( dirname $SOURCE ) )"
# Get the real path of config dir (resolve symlinks)
DOTFILES_CONFIG_DIR="$(readlink -f $CONFIG_DIR)"
# Get the dotfiles directory (parent folder)
export DOTFILES_DIR="$(dirname $DOTFILES_CONFIG_DIR)"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

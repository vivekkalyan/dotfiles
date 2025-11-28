eval "$(/opt/homebrew/bin/brew shellenv)"

# OS
if [ "$(uname -s)" = "Darwin" ]; then
  export OS="macOS"
else
  export OS=$(uname -s)
fi

# Get path to this file, resolve the symlink chain, then go up two levels
# ~/.config/zsh/.zprofile -> nix store -> dotfiles/config/zsh/.zprofile
SOURCE=${(%):-%N}
ZSH_CONFIG_DIR="$(dirname $SOURCE)"
REAL_ZSH_CONFIG_DIR="$(readlink -f $ZSH_CONFIG_DIR)"
export DOTFILES_DIR="$(dirname $(dirname $REAL_ZSH_CONFIG_DIR))"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

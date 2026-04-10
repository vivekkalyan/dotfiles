#!/usr/bin/env bash

set -euo pipefail

DEFAULT_REPO_URL="git@github.com:vivekkalyan/dotfiles.git"
REPO_URL="${DOTFILES_REPO_URL:-$DEFAULT_REPO_URL}"
REPO_DIR="${DOTFILES_REPO_DIR:-$HOME/personal/dotfiles}"
FLAKE_HOST="${DOTFILES_DARWIN_HOST:-cw}"
FLAKE_SUBDIR="nix"
DETERMINATE_INSTALL_URL="https://install.determinate.systems/nix"

log() {
  printf '[bootstrap] %s\n' "$*"
}

warn() {
  printf '[bootstrap] %s\n' "$*" >&2
}

die() {
  warn "$*"
  exit 1
}

keep_sudo_alive() {
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" >/dev/null 2>&1 || exit
  done 2>/dev/null &
}

script_repo_root() {
  local script_dir repo_root

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if repo_root="$(git -C "$script_dir/../.." rev-parse --show-toplevel 2>/dev/null)"; then
    printf '%s\n' "$repo_root"
  fi
}

ensure_macos() {
  [ "$(uname -s)" = "Darwin" ] || die "This bootstrap script is for macOS only."
}

ensure_sudo() {
  sudo -v
  keep_sudo_alive
}

refresh_nix_env() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  if [ -x /nix/var/nix/profiles/default/bin/nix ]; then
    export PATH="/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:$PATH"
  fi

  if ! command -v nix >/dev/null 2>&1 && [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    set +u
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    set -u
  fi
}

ensure_nix() {
  refresh_nix_env
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  log "Installing Determinate Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L "$DETERMINATE_INSTALL_URL" | sh -s -- install --no-confirm
  refresh_nix_env
  command -v nix >/dev/null 2>&1 || die "Nix installed but is not in PATH yet. Open a new shell and rerun."
}

ensure_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    return
  fi

  log "Requesting Xcode Command Line Tools install"
  xcode-select --install || true
  die "Install Xcode Command Line Tools, then rerun bootstrap."
}

refresh_brew_env() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    # shellcheck disable=SC2046
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

ensure_homebrew() {
  refresh_brew_env
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Installing Homebrew because cw uses nix-darwin's Homebrew module"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  refresh_brew_env
  command -v brew >/dev/null 2>&1 || die "Homebrew installed but is not in PATH yet. Open a new shell and rerun."
}

ensure_repo() {
  local repo_parent repo_root

  repo_root="$(script_repo_root || true)"
  if [ -n "$repo_root" ] && [ -f "$repo_root/$FLAKE_SUBDIR/flake.nix" ]; then
    REPO_DIR="$repo_root"
  fi

  if [ -d "$REPO_DIR/.git" ]; then
    log "Using existing dotfiles repo at $REPO_DIR"
    if git -C "$REPO_DIR" diff --quiet && git -C "$REPO_DIR" diff --cached --quiet; then
      log "Updating dotfiles repo"
      git -C "$REPO_DIR" pull --ff-only
    else
      warn "Skipping git pull because $REPO_DIR has local changes"
    fi
  elif [ -e "$REPO_DIR" ]; then
    die "$REPO_DIR exists but is not a git repository"
  else
    repo_parent="$(dirname "$REPO_DIR")"
    mkdir -p "$repo_parent"
    log "Cloning dotfiles repo to $REPO_DIR"
    if ! git clone "$REPO_URL" "$REPO_DIR"; then
      die "Git clone failed. If SSH is not set up yet, add your GitHub SSH key or rerun with DOTFILES_REPO_URL set to another clone URL."
    fi
  fi

  [ -f "$REPO_DIR/$FLAKE_SUBDIR/flake.nix" ] || die "Missing flake at $REPO_DIR/$FLAKE_SUBDIR/flake.nix"
}

run_switch() {
  local flake_path nix_bin darwin_rebuild_bin

  flake_path="$REPO_DIR/$FLAKE_SUBDIR#$FLAKE_HOST"
  log "Switching nix-darwin with $flake_path"

  if darwin_rebuild_bin="$(command -v darwin-rebuild 2>/dev/null)"; then
    sudo "$darwin_rebuild_bin" switch --flake "$flake_path"
    return
  fi

  nix_bin="$(command -v nix)"
  sudo "$nix_bin" run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake "$flake_path"
}

main() {
  ensure_macos
  ensure_sudo
  ensure_xcode_clt
  ensure_nix
  ensure_homebrew
  ensure_repo
  run_switch
  log "Bootstrap complete"
}

main "$@"

{ config, lib, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
  oos = config.lib.file.mkOutOfStoreSymlink;
in {
  home.username = "vkalyan";
  home.homeDirectory = "/Users/vkalyan";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    git ripgrep fd jq tmux fzf bat eza keepassxc mise
  ];

  # PATH: nix, personal bin, and mise shims
  home.sessionPath = [
    "${homeDir}/.local/bin"
    "${homeDir}/.nix-profile/bin"
    "${homeDir}/.local/share/mise/shims"
  ];

  xdg.configFile."mise/config.toml" = {
    source = oos "${homeDir}/personal/dotfiles/config/mise/config.toml";
  };
  xdg.configFile."nvim" = {
    source = oos "${homeDir}/personal/dotfiles/config/nvim";
  };
  xdg.configFile."tmux/tmux.conf" = {
    source = oos "${homeDir}/personal/dotfiles/config/tmux/tmux.conf";
  };
  xdg.configFile."git/config" = {
    source = oos "${homeDir}/personal/dotfiles/config/git/config";
  };
  xdg.configFile."git/config-os" = {
    source = oos "${homeDir}/personal/dotfiles/config/git/config-darwin";
  };

  # Optional: enable HM's mise module if present
  programs.mise.enable = true;

  # Safe program enables; avoid zsh/tmux here while linking their dotfiles
  programs.neovim.enable = true;

  # Link .app bundles from nix profile into ~/Applications
  home.activation.linkNixApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${homeDir}/Applications"
    for app in "${homeDir}/.nix-profile/Applications/"*.app; do
      [ -e "$app" ] || continue
      ln -sfn "$app" "${homeDir}/Applications/$(basename "$app")"
    done
  '';
}

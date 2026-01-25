{ config, lib, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
  oos = config.lib.file.mkOutOfStoreSymlink;
in {
  home.username = "vkalyan";
  home.homeDirectory = "/Users/vkalyan";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    coreutils
    curl
    eza
    fd
    fzf
    git
    gnumake
    hledger
    jq
    keepassxc
    llama-cpp
    mise
    neovim
    prek
    ripgrep
    tmux
    typst
    uv
    zoxide
    # for skypilot[kubernetes]
    kubectl
    netcat-gnu
    socat
  ];

  # PATH: nix, personal bin, and mise shims
  home.sessionPath = [
    "${homeDir}/.local/bin"
    "${homeDir}/.nix-profile/bin"
    "${homeDir}/.local/share/mise/shims"
  ];

  xdg.configFile."mise" = {
    source = oos "${homeDir}/personal/dotfiles/config/mise";
  };
  xdg.configFile."nvim" = {
    source = oos "${homeDir}/personal/dotfiles/config/nvim";
  };
  xdg.configFile."ghostty" = {
    source = oos "${homeDir}/personal/dotfiles/config/ghostty";
  };
  xdg.configFile."karabiner" = {
    source = oos "${homeDir}/personal/dotfiles/config/karabiner";
  };
  xdg.configFile."tmux" = {
    source = oos "${homeDir}/personal/dotfiles/config/tmux";
  };
  xdg.configFile."zsh" = {
    source = oos "${homeDir}/personal/dotfiles/config/zsh";
  };
  home.file.".zshenv" = {
    source = oos "${homeDir}/personal/dotfiles/config/zsh/zshenv";
  };
  home.file.".claude/settings.json" = {
    source = oos "${homeDir}/personal/dotfiles/config/claude/settings.json";
  };
  home.file.".claude/commands" = {
    source = oos "${homeDir}/personal/dotfiles/config/claude/commands";
  };
  home.file.".claude/hooks" = {
    source = oos "${homeDir}/personal/dotfiles/config/claude/hooks";
  };
  home.file.".claude/statusline-command.sh" = {
    source = oos "${homeDir}/personal/dotfiles/config/claude/statusline-command.sh";
  };
  xdg.configFile."git/config" = {
    source = oos "${homeDir}/personal/dotfiles/config/git/config";
  };
  xdg.configFile."git/config-os" = {
      text = ''
        [core]
          # It gets the path to the git package and builds the full script path.
          pager = ${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight | less --tabs=4 -RFX

        [interactive]
          diffFilter = ${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight
      '';
    };

  # Link .app bundles from nix profile into ~/Applications
  home.activation.linkNixApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${homeDir}/Applications"
    for app in "${homeDir}/.nix-profile/Applications/"*.app; do
      [ -e "$app" ] || continue
      ln -sfn "$app" "${homeDir}/Applications/$(basename "$app")"
    done
  '';
}

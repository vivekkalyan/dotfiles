{
  config,
  lib,
  pkgs,
  username ? "vkalyan",
  homeDirectory ? "/Users/${username}",
  dotfilesDir ? "${homeDirectory}/personal/dotfiles",
  workDir ? null,
  includeAgentConfig ? pkgs.stdenv.isDarwin,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  oos = config.lib.file.mkOutOfStoreSymlink;
  repoSkills = builtins.attrNames (lib.filterAttrs (_: type: type == "directory")
    (builtins.readDir ../config/skills));
  commonPackages = with pkgs; [
    bat
    bun
    codex
    coreutils
    curl
    eza
    fd
    fzf
    gh
    git
    gnumake
    jq
    kubectl
    less
    neovim
    netcat-gnu
    nodejs_24
    openssh
    prek
    ripgrep
    socat
    tmux
    typst
    unzip
    uv
    zoxide
    zsh
  ];
  darwinPackages = with pkgs; [
    hledger
    keepassxc
    llama-cpp
  ];
  linuxPackages = with pkgs; [
    file
    htop
    procps
    psmisc
    xclip
  ];
in lib.mkMerge [
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.05";

  home.packages =
    commonPackages
    ++ lib.optionals pkgs.stdenv.isDarwin darwinPackages
    ++ lib.optionals pkgs.stdenv.isLinux linuxPackages;

  # PATH: nix-managed tools plus personal scripts.
  home.sessionPath = [
    "${homeDir}/.local/bin"
    "${homeDir}/.nix-profile/bin"
  ];

  # Keep uv's cache beside dev-pod workspaces so installs can hardlink into
  # project venvs instead of copying across PVC subPath mounts.
  home.sessionVariables = lib.mkIf (workDir != null) {
    UV_CACHE_DIR = "${workDir}/.cache/uv";
  };

  xdg.configFile."nvim" = {
    source = oos "${dotfilesDir}/config/nvim";
  };
  xdg.configFile."tmux" = {
    source = oos "${dotfilesDir}/config/tmux";
  };
  xdg.configFile."zsh" = {
    source = oos "${dotfilesDir}/config/zsh";
  };
  home.file.".zshenv" = {
    source = oos "${dotfilesDir}/config/zsh/zshenv";
  };
  xdg.configFile."git/config" = {
    source = oos "${dotfilesDir}/config/git/config";
  };
  xdg.configFile."git/ignore" = {
    source = oos "${dotfilesDir}/config/git/ignore";
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

}
{
  xdg.configFile."ghostty" = lib.mkIf pkgs.stdenv.isDarwin {
    source = oos "${dotfilesDir}/config/ghostty";
  };
  xdg.configFile."karabiner" = lib.mkIf pkgs.stdenv.isDarwin {
    source = oos "${dotfilesDir}/config/karabiner";
  };

  # Link .app bundles from nix profile into ~/Applications
  home.activation.linkNixApps = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${homeDir}/Applications"
      for app in "${homeDir}/.nix-profile/Applications/"*.app; do
        [ -e "$app" ] || continue
        ln -sfn "$app" "${homeDir}/Applications/$(basename "$app")"
      done
    ''
  );
}
{
  home.file.".claude/settings.json" = lib.mkIf includeAgentConfig {
    source = oos "${dotfilesDir}/config/claude/settings.json";
  };
  home.file.".claude/CLAUDE.md" = lib.mkIf includeAgentConfig {
    source = oos "${dotfilesDir}/config/claude/CLAUDE.md";
  };
  home.file.".claude/commands" = lib.mkIf includeAgentConfig {
    source = oos "${dotfilesDir}/config/claude/commands";
  };
  home.file.".claude/hooks" = lib.mkIf includeAgentConfig {
    source = oos "${dotfilesDir}/config/claude/hooks";
  };
  home.file.".claude/skills" = lib.mkIf includeAgentConfig {
    source = oos "${dotfilesDir}/config/skills";
  };
  home.file.".claude/statusline-command.sh" = lib.mkIf includeAgentConfig {
    source = oos "${dotfilesDir}/config/claude/statusline-command.sh";
  };
}
{
  home.file = lib.mkIf includeAgentConfig (lib.listToAttrs (map (name: {
    name = ".codex/skills/user/${name}";
    value = {
      source = oos "${dotfilesDir}/config/skills/${name}";
    };
  }) repoSkills));
}
]

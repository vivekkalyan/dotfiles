{
  config,
  lib,
  pkgs,
  dotfilesDir,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  oos = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    codex
    hledger
    keepassxc
    llama-cpp
  ];

  # Paseo writes settings changes through this link, so it stays out of the Nix store. Both
  # hosts share the plugin switch and provider models; checkPaseoConfig warns when they drift.
  home.file.".paseo/config.json" = {
    source = oos "${dotfilesDir}/config/paseo/mac.json";
  };

  xdg.configFile."ghostty" = {
    source = oos "${dotfilesDir}/config/ghostty";
  };
  xdg.configFile."karabiner" = {
    source = oos "${dotfilesDir}/config/karabiner";
  };

  # Link .app bundles from nix profile into ~/Applications
  home.activation.linkNixApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${homeDir}/Applications"
    for app in "${homeDir}/.nix-profile/Applications/"*.app; do
      [ -e "$app" ] || continue
      ln -sfn "$app" "${homeDir}/Applications/$(basename "$app")"
    done
  '';

  home.file.".claude/settings.json" = {
    source = oos "${dotfilesDir}/config/claude/settings.json";
  };
  home.file.".claude/commands" = {
    source = oos "${dotfilesDir}/config/claude/commands";
  };
  home.file.".claude/hooks" = {
    source = oos "${dotfilesDir}/config/claude/hooks";
  };
  home.file.".claude/statusline-command.sh" = {
    source = oos "${dotfilesDir}/config/claude/statusline-command.sh";
  };
}

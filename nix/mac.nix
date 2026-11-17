{
  config,
  lib,
  pkgs,
  dotfilesDir,
  workDir,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  oos = config.lib.file.mkOutOfStoreSymlink;
  # Load this host's API keys for one command; the workspace AGENTS.md tells
  # agents to use it. The Mac keeps them in a hand-maintained .env.
  withKeys = pkgs.writeShellScriptBin "with-keys" ''
    set -euo pipefail
    [ $# -gt 0 ] || { echo "usage: with-keys <command> [args...]" >&2; exit 2; }
    env_file="${workDir}/.env"
    [ -r "$env_file" ] || { echo "with-keys: $env_file not found" >&2; exit 1; }
    set -a
    . "$env_file"
    set +a
    exec "$@"
  '';
in
{
  home.packages = with pkgs; [
    codex
    hledger
    keepassxc
    withKeys
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

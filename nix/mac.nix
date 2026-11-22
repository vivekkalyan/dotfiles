{
  config,
  pkgs,
  dotfilesDir,
  workDir,
  ...
}:
let
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

  # Copy Nix apps into ~/Applications/Home Manager Apps rather than linking them,
  # so Dock pins and Spotlight see a stable path and each switch restores the
  # pinned bundle if an app's own updater replaced it.
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;

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

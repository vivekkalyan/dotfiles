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
  # Keep Codex SQLite runtime state off PVC-backed home; auth and config still
  # persist under CODEX_HOME.
  codex = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    export CODEX_SQLITE_HOME="''${CODEX_SQLITE_HOME:-/tmp/codex/sqlite}"
    mkdir -p "$CODEX_SQLITE_HOME"

    exec ${pkgs.codex}/bin/codex \
      -c "sqlite_home=\"$CODEX_SQLITE_HOME\"" \
      "$@"
  '';
  # Load this host's API keys for one command; the workspace AGENTS.md tells
  # agents to use it. The Deployment mounts one file per key.
  withKeys = pkgs.writeShellScriptBin "with-keys" ''
    set -euo pipefail
    [ $# -gt 0 ] || { echo "usage: with-keys <command> [args...]" >&2; exit 2; }
    keys_dir=/run/secrets/api-keys
    [ -d "$keys_dir" ] || { echo "with-keys: $keys_dir not found" >&2; exit 1; }
    for f in "$keys_dir"/*; do
      [ -f "$f" ] || continue
      IFS= read -r value < "$f" || true
      export "$(basename "$f")=$value"
    done
    exec "$@"
  '';
in
{
  home.packages = with pkgs; [
    codex
    file
    htop
    obsidian-headless
    procps
    psmisc
    xclip
    withKeys
  ];

  home.sessionVariables = {
    # SSH login shells do not inherit the container environment. Keep kubectl
    # pointed at the read-only multi-cluster config mounted by the Deployment.
    KUBECONFIG = "/run/secrets/kubeconfig/config";
    # Keep Codex SQLite runtime state node-local; auth/config stay in CODEX_HOME.
    CODEX_SQLITE_HOME = "/tmp/codex/sqlite";
  };

  home.file.".paseo/config.json" = {
    source = oos "${dotfilesDir}/config/paseo/dev-pod.json";
  };

  home.activation.ensureSkyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sky_config="${homeDir}/.sky/config.yaml"

    if [ ! -e "$sky_config" ]; then
      mkdir -p "$(dirname "$sky_config")"
      chmod 700 "$(dirname "$sky_config")"
      cat > "$sky_config" <<'EOF'
kubernetes:
  remote_identity: vivek-dev
EOF
      chmod 600 "$sky_config"
    fi
  '';

  home.activation.linkCodexRuntimeDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    codex_home="${homeDir}/.codex"
    codex_runtime_root="/tmp/codex"

    mkdir -p "$codex_home" "$codex_runtime_root/tmp"

    link_codex_runtime_dir() {
      name="$1"
      source="$codex_runtime_root/$name"
      target="$codex_home/$name"

      mkdir -p "$source"

      if [ -L "$target" ]; then
        current_target="$(readlink "$target")"
        if [ "$current_target" = "$source" ]; then
          return
        fi
        rm -f "$target"
      fi

      if [ -e "$target" ]; then
        mv "$target" "$target.pre-node-local.$(date -u +%Y%m%dT%H%M%SZ)"
      fi

      ln -s "$source" "$target"
    }

    link_codex_runtime_dir tmp

    # Codex app-server currently expects this path to be a real directory, not
    # a symlink, so keep it under CODEX_HOME and clean stale control artifacts.
    app_server_control="$codex_home/app-server-control"
    if [ -L "$app_server_control" ]; then
      rm -f "$app_server_control"
    fi
    if [ -e "$app_server_control" ] && [ ! -d "$app_server_control" ]; then
      mv "$app_server_control" "$app_server_control.pre-node-local.$(date -u +%Y%m%dT%H%M%SZ)"
    fi
    mkdir -p "$app_server_control"
    rm -f "$app_server_control"/app-server-control.sock "$app_server_control"/app-server-startup.lock
  '';
}

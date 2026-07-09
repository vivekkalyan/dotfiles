{
  config,
  lib,
  pkgs,
  username ? "vkalyan",
  homeDirectory ? "/Users/${username}",
  dotfilesDir ? "${homeDirectory}/personal/dotfiles",
  agentsDir ? if workDir != null then "${workDir}/personal/agents" else "${homeDirectory}/personal/agents",
  agentsRepoUrl ? "git@github.com:vivekkalyan/agents.git",
  workDir ? null,
  includeAgentConfig ? pkgs.stdenv.isDarwin,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  oos = config.lib.file.mkOutOfStoreSymlink;
  skillsDir = "${agentsDir}/skills";
  codexPackage =
    if pkgs.stdenv.isLinux && workDir != null then
      # Keep Codex SQLite runtime state off PVC-backed home on dev pods; auth and
      # config still persist under CODEX_HOME.
      pkgs.writeShellScriptBin "codex" ''
        set -euo pipefail

        export CODEX_SQLITE_HOME="''${CODEX_SQLITE_HOME:-/tmp/codex/sqlite}"
        mkdir -p "$CODEX_SQLITE_HOME"

        exec ${pkgs.codex}/bin/codex \
          -c "sqlite_home=\"$CODEX_SQLITE_HOME\"" \
          "$@"
      ''
    else
      pkgs.codex;
  commonPackages = with pkgs; [
    bat
    bun
    pkgs."claude-code"
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
    pkgs."pi-coding-agent"
    prek
    ripgrep
    rsync
    socat
    tmux
    typst
    unzip
    uv
    zoxide
    zsh
    codexPackage
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

  home.sessionVariables = lib.mkIf (workDir != null) {
    # Keep repo-interacting caches beside dev-pod workspaces so tools can
    # hardlink into project venvs instead of copying across PVC subPath mounts.
    UV_CACHE_DIR = "${workDir}/.cache/uv";
    # Keep Codex SQLite runtime state node-local; auth/config stay in CODEX_HOME.
    CODEX_SQLITE_HOME = "/tmp/codex/sqlite";
  };

  home.activation.ensureSkyConfig = lib.mkIf (pkgs.stdenv.isLinux && workDir != null) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    ''
  );

  home.activation.linkCodexRuntimeDirs = lib.mkIf (pkgs.stdenv.isLinux && workDir != null) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    ''
  );

  home.activation.ensureAgentsRepo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    agents_dir="${agentsDir}"
    agents_repo_url="${agentsRepoUrl}"
    agents_parent="$(dirname "$agents_dir")"

    mkdir -p "$agents_parent"

    if [ -d "$agents_dir/.git" ]; then
      :
    elif [ -e "$agents_dir" ] && [ -n "$(${pkgs.findutils}/bin/find "$agents_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
      echo "WARNING: $agents_dir exists and is not an empty git checkout; not cloning agents." >&2
    else
      rm -rf "$agents_dir"
      if GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
        ${pkgs.git}/bin/git clone "$agents_repo_url" "$agents_dir"; then
        :
      else
        echo "WARNING: failed to clone agents from $agents_repo_url; creating empty $agents_dir" >&2
        mkdir -p "$agents_dir"
      fi
    fi
  '';

  home.activation.linkSkills = lib.hm.dag.entryAfter [ "ensureAgentsRepo" ] ''
    skills_dir="${skillsDir}"

    mkdir -p "$skills_dir" "${homeDir}/.codex/skills" "${homeDir}/.claude"

    link_skills() {
      target="$1"

      if [ -L "$target" ]; then
        current_target="$(readlink "$target")"
        if [ "$current_target" = "$skills_dir" ]; then
          return
        fi
        rm -f "$target"
      fi

      if [ -e "$target" ]; then
        mv "$target" "$target.pre-skills.$(date -u +%Y%m%dT%H%M%SZ)"
      fi

      ln -s "$skills_dir" "$target"
    }

    link_skills "${homeDir}/.codex/skills/user"
    link_skills "${homeDir}/.claude/skills"
  '';

  home.activation.linkCodexAgentInstructions = lib.hm.dag.entryAfter [ "ensureAgentsRepo" ] ''
    source="${agentsDir}/AGENTS.md"
    target="${homeDir}/.codex/AGENTS.md"

    mkdir -p "$(dirname "$target")"

    if [ ! -f "$source" ]; then
      echo "WARNING: $source is missing; not linking Codex instructions." >&2
    elif [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
      :
    else
      if [ -L "$target" ] || { [ -f "$target" ] && [ ! -s "$target" ]; }; then
        rm -f "$target"
      elif [ -e "$target" ]; then
        mv "$target" "$target.pre-agents.$(date -u +%Y%m%dT%H%M%SZ)"
      fi

      ln -s "$source" "$target"
    fi
  '';

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
  home.file.".claude/statusline-command.sh" = lib.mkIf includeAgentConfig {
    source = oos "${dotfilesDir}/config/claude/statusline-command.sh";
  };
}
]

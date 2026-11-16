{
  config,
  lib,
  pkgs,
  username,
  homeDirectory,
  workDir,
  dotfilesDir,
  agentsDir,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  oos = config.lib.file.mkOutOfStoreSymlink;
  agentsRepoUrl = "git@github.com:vivekkalyan/agents.git";
  skillsDir = "${agentsDir}/skills";
  workspaceAgentInstructionsDir = "${agentsDir}/workspace";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    age
    bat
    bun
    cargo
    pkgs."claude-code"
    clippy
    coreutils
    curl
    eza
    fd
    fzf
    gh
    git
    gnumake
    herdr
    jq
    pkgs."kimi-code"
    kubectl
    less
    neovim
    netcat-gnu
    nodejs_26
    openssh
    pkgs."pi-coding-agent"
    pnpm_12
    prek
    ripgrep
    rsync
    rust-analyzer
    rustc
    rustfmt
    socat
    temporal-cli
    tmux
    typst
    unzip
    uv
    zoxide
    zsh
  ];

  # PATH: nix-managed tools plus personal scripts.
  home.sessionPath = [
    "${homeDir}/.local/bin"
    "${homeDir}/.nix-profile/bin"
  ];

  home.sessionVariables = {
    WT_ROOT = workDir;
    # Keep uv's cache on the workspace filesystem so uv can hardlink into project
    # venvs; on the dev pod, home and /workspace are separate PVC subPath mounts.
    UV_CACHE_DIR = "${workDir}/.cache/uv";
    # OpenSSH does not preserve TZ/TZDIR from the dev pod's container environment.
    TZ = "America/Los_Angeles";
    TZDIR = "/usr/share/zoneinfo";
  };

  # Every link below points into these checkouts; refuse to activate without them.
  home.activation.checkCheckouts = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    if [ ! -d "${dotfilesDir}/.git" ]; then
      echo "error: dotfiles checkout not found at ${dotfilesDir}" >&2
      exit 1
    fi
  '';

  home.activation.checkPaseoConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    paseo_shared='{pluginsEnabled, providers: (.agents.providers | map_values(del(.command)))}'
    if ! diff -q \
      <(${pkgs.jq}/bin/jq -S "$paseo_shared" "${dotfilesDir}/config/paseo/dev-pod.json") \
      <(${pkgs.jq}/bin/jq -S "$paseo_shared" "${dotfilesDir}/config/paseo/mac.json") >/dev/null; then
      echo "warning: Paseo plugin or provider settings differ between config/paseo/dev-pod.json and mac.json" >&2
    fi
  '';

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

    mkdir -p "$skills_dir" "${homeDir}/.codex/skills" "${homeDir}/.claude" "${homeDir}/.pi/agent"

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
    link_skills "${homeDir}/.pi/agent/skills"
  '';

  home.activation.linkWorkspaceAgentInstructions = lib.hm.dag.entryAfter [ "ensureAgentsRepo" ] ''
    instructions_dir="${workspaceAgentInstructionsDir}"

    mkdir -p "${workDir}"

    for name in AGENTS.md CLAUDE.md; do
      source="$instructions_dir/$name"
      target="${workDir}/$name"

      if [ ! -f "$source" ]; then
        echo "WARNING: $source is missing; not linking workspace instructions." >&2
      elif [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        :
      else
        if [ -L "$target" ]; then
          rm -f "$target"
        elif [ -e "$target" ]; then
          mv "$target" "$target.pre-agents.$(date -u +%Y%m%dT%H%M%SZ)"
        fi

        ln -s "$source" "$target"
      fi
    done
  '';

  xdg.configFile."nvim" = {
    source = oos "${dotfilesDir}/config/nvim";
  };
  xdg.configFile."tmux" = {
    source = oos "${dotfilesDir}/config/tmux";
  };
  xdg.configFile."herdr/config.toml" = {
    source = oos "${dotfilesDir}/config/herdr/config.toml";
  };
  # Task worktree manager; WT_ROOT points it at workDir.
  home.file.".local/bin/wt" = {
    source = oos "${agentsDir}/scripts/wt";
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

  home.file.".pi/agent/settings.json" = {
    source = oos "${dotfilesDir}/config/pi/agent/settings.json";
    force = true;
  };
}

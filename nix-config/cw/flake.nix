{
  description = "User-space setup via Home Manager + nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-darwin, ... }:
  let
    system = "aarch64-darwin";
    unstable = import nixpkgs-unstable { inherit system; };
    overlay = _final: _prev: {
      prek = unstable.prek;
    };
    pkgs   = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
    };
  in {
    # Home Manager-only build
    homeConfigurations."cw" =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };

    # nix-darwin system with Home Manager integrated
    darwinConfigurations."cw" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [ overlay ];
          system.stateVersion = 6;
          system.primaryUser  = "vkalyan";

          # Run HM for this user
          users.users.vkalyan.home = "/Users/vkalyan";
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages = true;
          home-manager.users.vkalyan = import ./home.nix;

          # disable nix
          nix.enable = false;

          # Bellevue, Washington: Pacific Time with US locale/region defaults.
          time.timeZone = "America/Los_Angeles";

          # Install macOS apps (e.g., Raycast) via Homebrew casks
          homebrew.enable = true;
          homebrew.onActivation = {
            autoUpdate = true;
            upgrade = true;
            cleanup = "zap";
          };
          homebrew.casks = [
            "claude"
            "claude-code"
            "codex"
            "cursor"
            "flux-app"
            "font-meslo-lg-nerd-font"
            "ghostty"
            "handy"
            "inkscape"
            "karabiner-elements"
            "obsidian"
            "raycast"
            "todoist-app"
            "zen"
          ];

          # Dock size (pixels).
          system.defaults.dock.tilesize = 16;

          # Disable macOS shortcuts that conflict with terminal/editor keybindings
          # ID 32 = Mission Control (ctrl+up)
          # ID 33 = Application Windows (ctrl+down)
          # ID 60 = Select previous input source (ctrl+space)
          # ID 64 = Show Spotlight search (cmd+space)
          system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
            AppleSymbolicHotKeys = {
              "32" = { enabled = false; };
              "33" = { enabled = false; };
              "60" = { enabled = false; };
              "64" = { enabled = false; };
            };
          };

          # Keyboard repeat settings (lower = faster)
          # KeyRepeat: delay between repeated characters (default: 6, range: 1-15)
          # InitialKeyRepeat: delay before repeat starts (default: 25, range: 15-120)
          system.defaults.NSGlobalDomain.KeyRepeat = 2;
          system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;

          # Mouse sensitivity (higher = more sensitive, range: -1.0 to 1.0)
          # Using CustomUserPreferences for settings not directly exposed by nix-darwin
          system.defaults.CustomUserPreferences."com.apple.mouse".scaling = 1.0;

          # Disable autocorrect
          system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

          # Keep macOS language/region defaults aligned with the current location.
          system.defaults.CustomUserPreferences.".GlobalPreferences" = {
            Country = "US";
            AppleLocale = "en_US";
            AppleLanguages = [ "en-US" ];
          };
          system.defaults.CustomSystemPreferences."/Library/Preferences/.GlobalPreferences" = {
            Country = "US";
            AppleLocale = "en_US";
            AppleLanguages = [ "en-US" ];
          };

          # Save screenshots to clipboard
          system.defaults.screencapture.target = "clipboard";

          # llama-server for local LLM inference (used by llama.vim)
          # Monitors power source: starts server on AC, stops on battery.
          launchd.user.agents.llama-server = {
            serviceConfig = {
              Label = "com.llama.server";
              ProgramArguments = [
                "${pkgs.writeShellScript "llama-power-wrapper" ''
                  cleanup() { [ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null; wait "$SERVER_PID" 2>/dev/null; }
                  trap cleanup EXIT

                  SERVER_PID=""
                  start_server() {
                    if [ -z "$SERVER_PID" ] || ! kill -0 "$SERVER_PID" 2>/dev/null; then
                      ${pkgs.llama-cpp}/bin/llama-server --fim-qwen-7b-default &
                      SERVER_PID=$!
                      echo "Started llama-server (pid $SERVER_PID)"
                    fi
                  }
                  stop_server() {
                    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
                      echo "Stopping llama-server (pid $SERVER_PID)"
                      kill "$SERVER_PID" 2>/dev/null
                      wait "$SERVER_PID" 2>/dev/null
                      SERVER_PID=""
                    fi
                  }
                  on_ac() { /usr/bin/pmset -g batt 2>/dev/null | head -1 | grep -q "AC Power"; }

                  while true; do
                    if on_ac; then
                      start_server
                    else
                      stop_server
                    fi
                    sleep 30
                  done
                ''}"
              ];
              RunAtLoad = true;
              KeepAlive = true;
              StandardOutPath = "/tmp/llama-server.log";
              StandardErrorPath = "/tmp/llama-server.err";
            };
          };

          # hivemind agent
          launchd.user.agents.hivemind = {
            serviceConfig = {
              Label = "com.hivemind.agent";
              ProgramArguments = [
                "${pkgs.uv}/bin/uvx"
                "--python"
                "3.13"
                "--from"
                "wandb-hivemind"
                "hivemind"
                "run"
              ];
              KeepAlive = true;
              RunAtLoad = true;
              StandardOutPath = "/tmp/hivemind.log";
              StandardErrorPath = "/tmp/hivemind.err.log";
            };
          };
        }
      ];
    };
  };
}

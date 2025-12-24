{
  description = "User-space setup via Home Manager + nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
  let
    system = "aarch64-darwin";
    pkgs   = import nixpkgs { inherit system; };
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
          system.stateVersion = 6;
          system.primaryUser  = "vkalyan";

          # Run HM for this user
          users.users.vkalyan.home = "/Users/vkalyan";
          home-manager.useUserPackages = true;
          home-manager.users.vkalyan = import ./home.nix;

          # disable nix
          nix.enable = false;

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
            "inkscape"
            "karabiner-elements"
            "macwhisper"
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
          # llama-server for local LLM inference (used by llama.vim)
          launchd.user.agents.llama-server = {
            serviceConfig = {
              Label = "com.llama.server";
              ProgramArguments = [
                "${pkgs.llama-cpp}/bin/llama-server"
                "--fim-qwen-7b-default"
              ];
              RunAtLoad = true;
              KeepAlive = true;
              StandardOutPath = "/tmp/llama-server.log";
              StandardErrorPath = "/tmp/llama-server.err";
            };
          };
        }
      ];
    };
  };
}

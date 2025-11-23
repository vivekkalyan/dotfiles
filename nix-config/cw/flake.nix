{
  description = "User-space setup via Home Manager + nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
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
            "claude-code"
            "codex"
            "cursor"
            "flux-app"
            "font-meslo-lg-nerd-font"
            "ghostty"
            "inkscape"
            "karabiner-elements"
            "keepassxc"
            "macwhisper"
            "obsidian"
            "raycast"
            "todoist-app"
            "zen"
          ];

          # Dock size (pixels).
          system.defaults.dock.tilesize = 16;
        }
      ];
    };
  };
}

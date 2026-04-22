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
      llama-cpp = unstable.llama-cpp;
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
        ./host.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [ overlay ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vkalyan = import ./home.nix;
        }
      ];
    };
  };
}

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
    darwinSystem = "aarch64-darwin";
    linuxSystem = "x86_64-linux";
    nixpkgsConfig = {
      allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
        "claude-code"
        "kimi-code"
        "pi-coding-agent"
      ];
    };

    mkOverlay = system:
      let
        unstable = import nixpkgs-unstable {
          inherit system;
          config = nixpkgsConfig;
        };
      in final: _prev: {
        codex = final.callPackage ./packages/codex-bin.nix { };
        kimi-code = final.callPackage ./packages/kimi-code-bin.nix { };
        claude-code = unstable.claude-code;
        pi-coding-agent = unstable.pi-coding-agent;
        prek = unstable.prek;
        uv = unstable.uv;
        llama-cpp = unstable.llama-cpp;
      };

    mkPkgs = system: import nixpkgs {
      inherit system;
      config = nixpkgsConfig;
      overlays = [ (mkOverlay system) ];
    };

    darwinPkgs = mkPkgs darwinSystem;
    linuxPkgs = mkPkgs linuxSystem;
    darwinOverlay = mkOverlay darwinSystem;

    mkHome = {
      pkgs,
      username,
      homeDirectory,
      dotfilesDir,
      agentsDir,
      agentsRepoUrl ? "git@github.com:vivekkalyan/agents.git",
      workDir ? null,
      includeAgentConfig ? pkgs.stdenv.isDarwin
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username homeDirectory dotfilesDir agentsDir agentsRepoUrl workDir includeAgentConfig;
        };
        modules = [ ./home.nix ];
      };
  in {
    # Home Manager-only build for the Mac.
    homeConfigurations."cw" = mkHome {
      pkgs = darwinPkgs;
      username = "vkalyan";
      homeDirectory = "/Users/vkalyan";
      dotfilesDir = "/Users/vkalyan/personal/dotfiles";
      agentsDir = "/Users/vkalyan/personal/agents";
      agentsRepoUrl = "git@github.com:vivekkalyan/agents.git";
      includeAgentConfig = true;
    };

    # Home Manager-only build for the dev pod.
    homeConfigurations."vivek-dev" = mkHome {
      pkgs = linuxPkgs;
      username = "root";
      homeDirectory = "/root";
      dotfilesDir = "/workspace/personal/dotfiles";
      agentsDir = "/workspace/personal/agents";
      agentsRepoUrl = "git@github.com:vivekkalyan/agents.git";
      workDir = "/workspace";
      includeAgentConfig = false;
    };

    # nix-darwin system with Home Manager integrated
    darwinConfigurations."cw" = nix-darwin.lib.darwinSystem {
      system = darwinSystem;
      modules = [
        ./host.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.config = nixpkgsConfig;
          nixpkgs.overlays = [ darwinOverlay ];
          home-manager.extraSpecialArgs = {
            username = "vkalyan";
            homeDirectory = "/Users/vkalyan";
            dotfilesDir = "/Users/vkalyan/personal/dotfiles";
            agentsDir = "/Users/vkalyan/personal/agents";
            agentsRepoUrl = "git@github.com:vivekkalyan/agents.git";
            workDir = null;
            includeAgentConfig = true;
          };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vkalyan = import ./home.nix;
        }
      ];
    };
  };
}

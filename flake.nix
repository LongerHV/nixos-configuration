{
  description = "My config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    neovim-plugins.url = "github:LongerHV/neovim-plugins-overlay";
    neovim-plugins.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , flake-utils
    , home-manager
    , neovim-nightly-overlay
    , agenix
    , deploy-rs
    , neovim-plugins
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
      systems = flake-utils.lib.system;
      defaultModules = [
        agenix.nixosModule
        home-manager.nixosModules.home-manager
      ];
    in
    rec {
      overlays = {
        default = import ./overlay/default.nix;
        unstable = final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        };
        neovimNightly = neovim-nightly-overlay.overlay;
        neovimPlugins = neovim-plugins.overlay;
        agenix = agenix.overlay;
      };

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
      });

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );

      nixosConfigurations = {
        mordor = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          specialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            ./nixos/mordor
          ];
        };
        nasgul = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            ./nixos/nasgul
          ];
        };
        golum = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            ./nixos/golum
          ];
        };
        isoimage = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            ./nixos/iso
          ];
        };
        playground = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            ./nixos/playground
          ];
        };
        smaug = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.aarch64-linux;
          system = systems.aarch64-linux;
          specialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./nixos/smaug
          ];
        };
      };

      homeConfigurations = {
        # Ubuntu at work
        mmieszczak = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs; };
          modules = (builtins.attrValues homeManagerModules) ++ [
            ./home-manager/work.nix
          ];
        };
      };

      deploy.nodes = {
        nasgul = {
          hostname = "nasgul.lan";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nasgul;
            sshUser = "longer";
            user = "root";
            sshOpts = [ "-t" ];
            magicRollback = false; # Disable because it breaks remote sudo :<
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

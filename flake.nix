{
  description = "My config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    my-overlay.url = "path:./overlay";
    my-overlay.inputs.nixpkgs.follows = "nixpkgs";
    neovim-plugins.url = "path:./neovim_plugins";
    neovim-plugins.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, neovim-nightly-overlay, agenix, my-overlay, neovim-plugins, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        # "aarch64-linux"
        "x86_64-linux"
      ];
      defaultModules = [
        agenix.nixosModule
        home-manager.nixosModules.home-manager
      ];
    in
    rec {
      overlays = {
        default = my-overlay.overlay;
        unstable = final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        };
        neovimNightly = neovim-nightly-overlay.overlay;
        neovimPlugins = neovim-plugins.overlay;
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
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            ./nixos/mordor
          ];
        };
        nasgul = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            ./nixos/nasgul
          ];
        };
        golum = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            ./nixos/golum
          ];
        };
        isoimage = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = (builtins.attrValues nixosModules) ++ defaultModules ++ [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
            ./nixos/iso
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
    };
}

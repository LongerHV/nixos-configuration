{
  description = "My config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    inputs.agenix.url = "github:ryantm/agenix";
  };
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, neovim-nightly-overlay, agenix, ... }:
    let
      isoModule = "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      overlays = [
        neovim-nightly-overlay.overlay
        overlay-unstable
      ];
      mkHost = username: modules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/hosts-common.nix
          agenix.nixosModule
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = overlays;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import ./home;
            users.users."${username}" = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
            };
          }
        ] ++ modules;
      };
      mkHome = username: imports: home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        configuration = { pkgs, ... }: {
          nixpkgs.overlays = overlays;
          imports = [ ./home/config/non-nixos.nix ] ++ imports;
        };
        stateVersion = "21.11";
      };
    in
    {
      # NixOS hosts configuration
      nixosConfigurations = {
        nasgul = mkHost "longer" [ ./hosts/nasgul ];
        isoimage = mkHost "nixos" [ isoModule ];
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        # Arch linux machine
        longer = mkHome "longer" [ ./home ];
        # Ubuntu at work
        mmieszczak = mkHome "mmieszczak" [ ./home/work.nix ];
      };
    };
}

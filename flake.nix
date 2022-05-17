{
  description = "My config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, neovim-nightly-overlay, ... }:
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
      nixosConfigurations = {
        nasgul = mkHost "longer" [ ./hosts/nasgul ];
        isoimage = mkHost "nixos" [ isoModule ];
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        longer = mkHome "longer" [ ./home ];
        mmieszczak = mkHome "mmieszczak" [ ./home/work.nix ];
      };
    };
}

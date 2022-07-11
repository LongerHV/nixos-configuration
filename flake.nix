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
    my-overlay.url = "path:./packages";
    my-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, neovim-nightly-overlay, agenix, my-overlay, ... }:
    let
      isoModule = "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      overlays = [
        neovim-nightly-overlay.overlay
        overlay-unstable
        my-overlay.overlay
      ];
      mkHost = { username ? "longer", modules ? [ ], home_import ? ./home }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/hosts-common.nix
          agenix.nixosModule
          ./modules
          home-manager.nixosModules.home-manager
          {
            mainUser = username;
            nixpkgs.overlays = overlays;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import home_import;
            users.users."${username}" = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" ];
            };
            environment.systemPackages = [ agenix.defaultPackage.x86_64-linux ];
          }
        ] ++ modules;
      };
      mkHome = { username ? "longer", imports ? [ ] }: home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        inherit username;
        homeDirectory = "/home/${username}";
        configuration = { pkgs, ... }: {
          nixpkgs.overlays = overlays;
          imports = [ ./home/config/non-nixos.nix ] ++ imports;
        };
      };
    in
    {
      # NixOS hosts configuration
      nixosConfigurations = {
        mordor = mkHost {
          home_import = ./home/mordor.nix;
          modules = [
            ./hosts/mordor
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-gpu-amd
          ];
        };
        nasgul = mkHost {
          modules = [
            ./hosts/nasgul
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-gpu-amd
          ];
        };
        isoimage = mkHost {
          username = "nixos";
          home_import = ./home/iso.nix;
          modules = [ ./hosts/iso isoModule ];
        };
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        # Ubuntu at work
        mmieszczak = mkHome {
          username = "mmieszczak";
          imports = [ ./home/work.nix ];
        };
      };
    };
}

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
      username = "longer";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      };
      overlays = [
        neovim-nightly-overlay.overlay
        overlay-unstable
      ];
      common_home_manager_module = {
        nixpkgs.overlays = overlays;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."${username}" = import ./home;
      };
    in
    {
      nixosConfigurations = {
        testvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/testvm
            home-manager.nixosModules.home-manager
            common_home_manager_module
          ];
        };
        nasgul = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nasgul
            home-manager.nixosModules.home-manager
            common_home_manager_module
          ];
        };
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        longer = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          inherit username;
          homeDirectory = "/home/${username}";
          configuration = { pkgs, ... }: {
            nixpkgs.overlays = overlays;
            imports = [ ./home ./home/config/non-nixos.nix ];
          };
          stateVersion = "21.11";
        };
      };
    };
}

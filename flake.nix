{
  description = "My config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "longer";
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
    in
    {
      nixosConfigurations = {
        testvm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/testvm
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = import ./homes/longer.nix;
            }
          ];
        };
      };

      # Standalone home-manager configuration for non-NixOS systems
      homeConfigurations = {
        longer = home-manager.lib.homeManagerConfiguration rec {
          inherit system username;
          homeDirectory = "/home/${username}";
          configuration = import ./homes/longer.nix;
          stateVersion = "21.11";
        };
      };
    };
}

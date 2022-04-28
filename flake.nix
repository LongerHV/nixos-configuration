{
  description = "My config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, neovim-nightly-overlay, ... }:
    let
      username = "longer";
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };
    in
    {
      nixosConfigurations = {
        testvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/testvm
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                neovim-nightly-overlay.overlay
                overlay-unstable
              ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = import ./homes/longer.nix;
            }
          ];
        };
      };

      # Standalone home-manager configuration for non-NixOS systems
      # homeConfigurations = {
      #   longer = home-manager.lib.homeManagerConfiguration rec {
      #     system = "x86_64-linux";
      #     inherit username;
      #     homeDirectory = "/home/${username}";
      #     configuration = import ./homes/longer.nix;
      #     stateVersion = "21.11";
      #   };
      # };
    };
}

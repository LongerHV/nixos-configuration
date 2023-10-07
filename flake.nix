{
  description = "My config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-prev.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:helix-editor/helix";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    neovim-plugins.url = "github:LongerHV/neovim-plugins-overlay";
    neovim-plugins.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixgl.url = "github:guibou/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-prev
    , nixpkgs-unstable
    , nixpkgs-master
    , nixos-hardware
    , home-manager
    , agenix
    , deploy-rs
    , neovim-plugins
    , helix
    , nixgl
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
    in
    rec {
      overlays = {
        default = import ./overlay/default.nix;
        unstable = final: prev: {
          previous = nixpkgs-prev.legacyPackages.${prev.system};
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
          master = nixpkgs-master.legacyPackages.${prev.system};
        };
        helix = final: prev: {
          inherit (helix.packages.${prev.system}) helix;
        };
        neovimPlugins = neovim-plugins.overlays.default;
        agenix = agenix.overlays.default;
        nixgl = nixgl.overlays.default;
      };

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./shell.nix { };
        node = nixpkgs.legacyPackages.${system}.callPackage ./shells/node.nix { };
        python = nixpkgs.legacyPackages.${system}.callPackage ./shells/python.nix { };
        pythonVenv = nixpkgs.legacyPackages.${system}.callPackage ./shells/pythonVenv.nix { };
        lint = nixpkgs.legacyPackages.${system}.callPackage ./shells/lint.nix { };
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".nixpkgs-fmt);

      templates = import ./templates;

      nixosConfigurations =
        let
          defaultModules = (builtins.attrValues nixosModules) ++ [
            agenix.nixosModules.default
            home-manager.nixosModules.default
          ];
          specialArgs = { inherit inputs outputs; };
        in
        {
          mordor = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./nixos/mordor
            ];
          };
          nasgul = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./nixos/nasgul
            ];
          };
          dol-guldur = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./nixos/dol-guldur
            ];
          };
          playground = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./nixos/playground
            ];
          };
          smaug = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./nixos/smaug
            ];
          };
          sd-image = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
              ./nixos/sd-image
            ];
          };
          isoimage = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
              ./nixos/iso
            ];
          };
          isoimage-server = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              { mySystem.user = "nixos"; }
            ];
          };
        };

      homeConfigurations = {
        # Ubuntu at work
        mmieszczak = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = (builtins.attrValues homeManagerModules) ++ [
            ./home-manager/work.nix
          ];
        };
      };

      deploy.nodes =
        let
          mkDeployConfig = hostname: configuration: {
            inherit hostname;
            profiles.system =
              let
                inherit (configuration.config.nixpkgs.hostPlatform) system;
              in
              {
                path = deploy-rs.lib."${system}".activate.nixos configuration;
                sshUser = "longer";
                user = "root";
                sshOpts = [ "-t" ];
                magicRollback = false; # Disable because it breaks remote sudo :<
              };
          };
        in
        {
          nasgul = mkDeployConfig "nasgul.lan" self.nixosConfigurations.nasgul;
          smaug = mkDeployConfig "smaug.lan" self.nixosConfigurations.smaug;
          dol-guldur = mkDeployConfig "dol-guldur.longerhv.xyz" self.nixosConfigurations.dol-guldur;
        };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

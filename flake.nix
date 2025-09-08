{
  description = "My config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-plugins = {
      url = "github:LongerHV/neovim-plugins-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xenon = {
      url = "github:LongerHV/xenon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kubectl = {
      url = "github:LongerHV/kubectl-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , home-manager
    , agenix
    , deploy-rs
    , neovim-plugins
    , xenon
    , kubectl
    , nixgl
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
      defaultOverlay = import ./overlay/default.nix;
      overlays = [
        neovim-plugins.overlays.default
        kubectl.overlays.default
        agenix.overlays.default
        nixgl.overlays.default
        (final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        })
        defaultOverlay
      ];
      nixosModules = import ./modules/nixos;
      homeManagerModules = (import ./modules/home-manager) // xenon.homeManagerModules;
      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        }
      );
    in
    {
      inherit legacyPackages nixosModules homeManagerModules;
      overlays.default = defaultOverlay;

      devShells = forAllSystems (system: {
        default = legacyPackages.${system}.callPackage ./shell.nix { };
        node = legacyPackages.${system}.callPackage ./shells/node.nix { };
        go = legacyPackages.${system}.callPackage ./shells/go.nix { };
        python = legacyPackages.${system}.callPackage ./shells/python.nix { };
        pythonPoetry = legacyPackages.${system}.callPackage ./shells/pythonPoetry.nix { };
        pythonUV = legacyPackages.${system}.callPackage ./shells/pythonUV.nix { };
        pythonVenv = legacyPackages.${system}.callPackage ./shells/pythonVenv.nix { };
        lint = legacyPackages.${system}.callPackage ./shells/lint.nix { };
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages."${system}".nixpkgs-fmt);

      templates = import ./templates;

      nixosConfigurations =
        let
          defaultModules = (builtins.attrValues nixosModules) ++ [
            agenix.nixosModules.default
            home-manager.nixosModules.default
          ];
          specialArgs = { inherit inputs outputs overlays; };
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
              { isoImage.squashfsCompression = "gzip -Xcompression-level 1"; }
              ./nixos/iso
            ];
          };
          isoimage-server = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            inherit specialArgs;
            modules = defaultModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              {
                isoImage.squashfsCompression = "gzip -Xcompression-level 1";
                mySystem.user = "nixos";
              }
            ];
          };
        };

      homeConfigurations = {
        # Ubuntu at work
        mmieszczak = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs overlays; };
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
                interactiveSudo = true;
              };
          };
        in
        {
          nasgul = mkDeployConfig "nasgul.lan" self.nixosConfigurations.nasgul;
          smaug = mkDeployConfig "smaug.lan" self.nixosConfigurations.smaug;
        };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: {
    overlay = nixpkgs.lib.composeManyExtensions [
      (final: prev: {
        myApp = prev.poetry2nix.mkPoetryApplication {
          projectDir = self;
        };
      })
    ];
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
    in
    {
      apps = {
        inherit (pkgs) myApp;
      };

      defaultApp = pkgs.myApp;

      devShell =
        let
          pythonPackages = pkgs.python310Packages;
        in
        pkgs.mkShellNoCC {
          buildInputs = with pythonPackages; [ python venvShellHook ];
          packages = [ pkgs.poetry ];
          venvDir = "./.venv";
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            poetry env use .venv/bin/python
            poetry install
          '';
          postShellHook = ''
            unset SOURCE_DATE_EPOCH
            poetry env info
          '';
        };
    }));
}

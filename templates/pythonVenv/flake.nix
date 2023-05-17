{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs.python3Packages; [ python venvShellHook ];
        venvDir = "./.venv";
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
        '';
        postShellHook = ''
          unset SOURCE_DATE_EPOCH
          export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib
        '';
      };
    }
  );
}

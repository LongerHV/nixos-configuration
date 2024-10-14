{ pkgs, ... }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    poetry
    python3Packages.python
    python3Packages.requests
  ];
}

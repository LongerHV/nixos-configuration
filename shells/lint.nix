{ pkgs, ... }:

pkgs.mkShellNoCC {
  nativeBuildInputs = with pkgs; [
    actionlint
    selene
    stylua
    statix
    nixpkgs-fmt
    yamllint
  ];
}

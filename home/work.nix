{ pkgs, ... }:

{
  imports = [
    ./config/cli-packages.nix
    ./config/devops.nix
  ];
}

{ pkgs, ... }:

{
  imports = [
    ./config/cli-packages.nix
    ./config/devops.nix
    ./config/dconf.nix
  ];
}

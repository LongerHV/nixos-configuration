{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    kubectl
    ansible
    terraform
  ];
}

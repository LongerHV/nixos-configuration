{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    kube3d
    kubectl
    helm
    ansible
    terraform
  ];
}

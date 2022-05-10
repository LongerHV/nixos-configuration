{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    kube3d
    kubectl
    kubernetes-helm
    ansible
    terraform
  ];
}

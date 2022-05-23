{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    kube3d
    kubectl
    kubernetes-helm
    azure-cli
    # ansible
    terraform
    poetry
  ];
}

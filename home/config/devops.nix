{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    ansible
    awscli2
    azure-cli
    eksctl
    k9s
    kube3d
    kubectl
    kubernetes-helm
    rancher
    teleport.client
    terraform
  ];
}

{ pkgs, ... }:

{
  home.packages = with pkgs.unstable; [
    k9s
    kube3d
    kubectl
    kubernetes-helm
    azure-cli
    awscli2
    eksctl
    ansible
    teleport.client
    terraform
  ];
}

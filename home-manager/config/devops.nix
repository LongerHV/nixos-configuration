{ pkgs, lib, ... }:

let
  kubesel = pkgs.writeShellScriptBin "kubesel" ''
    ls $HOME/.kube/*config | ${pkgs.fzf}/bin/fzf --height=10 | xargs -I {} cp "{}" "$HOME/.kube/config"
  '';
in
{
  home.packages = with pkgs.unstable; [
    ansible
    awscli2
    azure-cli
    certbot
    eksctl
    k9s
    kind
    kube3d
    kubectl
    kubelogin-oidc
    kubernetes-helm
    krew
    mariadb.client
    rancher
    teleport.client
    terraform
    tilt
  ] ++ [
    kubesel
  ];
}

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
    kube3d
    kubectl
    kubernetes-helm
    rancher
    teleport.client
    terraform
  ] ++ [
    kubesel
  ];
}

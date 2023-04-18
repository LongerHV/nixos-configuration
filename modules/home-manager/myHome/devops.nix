{ pkgs, config, lib, ... }:

let
  cfg = config.myHome.devops;
  kctx = with pkgs; (writeShellApplication {
    name = "kctx";
    runtimeInputs = [ kubectl fzf ];
    text = ''
      kubectl config get-contexts -o name | fzf --height=10 | xargs kubectl config use-context
    '';
  });
in
{
  options.myHome.devops.enable = lib.mkEnableOption "devops";
  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      act
      ansible
      awscli2
      azure-cli
      eksctl
      kind
      kube3d
      kubectl
      kubelogin-oidc
      kubernetes-helm
      kubeseal
      teleport.client
      terraform
      tilt
      unstable.fluxcd
      unstable.kubernetes-polaris
      unstable.kubeshark
      unstable.k9s
    ]) ++ [
      kctx
    ];
  };
}

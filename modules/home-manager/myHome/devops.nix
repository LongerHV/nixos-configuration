{ pkgs, config, lib, ... }:

let
  cfg = config.myHome.devops;
  kctx = with pkgs; (writeShellScriptBin "kctx"
    ''
      k=${kubectl}/bin/kubectl
      f=${fzf}/bin/fzf
      $k config get-contexts -o name | $f --height=10 | xargs $k config use-context
    ''
  );
in
{
  options.myHome.devops.enable = lib.mkEnableOption "devops";
  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      ansible
      awscli2
      azure-cli
      eksctl
      k9s
      kind
      kube3d
      kubectl
      kubelogin-oidc
      kubernetes-helm
      kubeseal
      unstable.kubeshark
      teleport.client
      terraform
      tilt
    ]) ++ [
      kctx
    ];
  };
}

{ pkgs, config, lib, ... }:

let
  cfg = config.myHome.cli;
  kcon = with pkgs; (writeShellScriptBin "kcon"
    ''
      k=${kubectl}/bin/kubectl
      f=${fzf}/bin/fzf
      $k config get-contexts -o name | $f --height=10 | xargs $k config use-context
    ''
  );
in
{
  options.myHome.cli.devops.enable = lib.mkEnableOption "devops";
  config = lib.mkIf (cfg.enable && cfg.devops.enable) {
    home.packages = (with pkgs; [
      act
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
      teleport.client
      terraform
      tilt
    ]) ++ [
      kcon
    ];
  };
}

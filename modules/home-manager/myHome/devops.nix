{ pkgs, config, lib, ... }:

let
  cfg = config.myHome.devops;
in
{
  options.myHome.devops.enable = lib.mkEnableOption "devops";
  config = lib.mkIf cfg.enable {
    programs.zsh.shellAliases = {
      tf = "terraform";
    };
    home.packages = with pkgs; [
      act
      ansible
      awscli2
      azure-cli
      eksctl
      fluxcd
      kind
      kubectl
      kubelogin
      kubelogin-oidc
      kubernetes-helm
      kubeseal
      minio-client
      mysql-client
      packer
      swiftclient
      terraform
      tilt
      unstable.k3d
      unstable.k9s
      unstable.kubernetes-polaris
      unstable.kubeshark
      unstable.openstackclient
      unstable.teleport.client
      (writeShellApplication {
        name = "kctx";
        runtimeInputs = [ kubectl fzf ];
        text = ''
          kubectl config get-contexts -o name \
          | fzf --height=10 \
          | xargs kubectl config use-context
        '';
      })
      (writeShellApplication {
        name = "kctn";
        runtimeInputs = [ kubectl fzf ];
        text = ''
          kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
            | fzf --height=10 \
            | xargs kubectl config set-context --current --namespace
        '';
      })
    ];
  };
}

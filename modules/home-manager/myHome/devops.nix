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
      kubectl-neat
      kubectl-tree
      kubelogin
      kubelogin-oidc
      kubernetes-helm
      kubeseal
      mariadb.client
      minio-client
      packer
      swiftclient
      terraform
      tilt
      unstable.clusterctl
      unstable.k3d
      unstable.kubernetes-polaris
      unstable.kubeshark
      unstable.openstackclient
      unstable.talosctl
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
      (writeShellApplication {
        name = "prod";
        runtimeInputs = [ ];
        text = ''
          tmux new -ds prod 2>/dev/null  # create if doesn't exist
          exec tmux attach -t prod
        '';
      })
    ];
    programs.k9s = {
      enable = true;
      package = pkgs.unstable.k9s;
      skins = {
        prod = {
          k9s = {
            body = {
              logoColor = "red";
            };
            dialog = {
              buttonFocusBgColor = "red";
            };
            frame = {
              border = {
                fgColor = "darkred";
                focusColor = "red";
              };
              menu = {
                keyColor = "red";
              };
            };
          };
        };
      };
    };
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.cli;
in
{
  options.myHome.cli = {
    enable = (lib.mkEnableOption "cli") // { default = true; };
    devops.enable = lib.mkEnableOption "devops";
    personalGitEnable = (lib.mkEnableOption "personalGitEnable") // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      gh.enable = true;
      zsh.shellAliases = {
        lg = "lazygit";
      };
      git = {
        enable = true;
        userName = lib.mkIf cfg.personalGitEnable "Michał Mieszczak";
        userEmail = lib.mkIf cfg.personalGitEnable "michal@mieszczak.com.pl";
      };
    };
    home.packages = builtins.concatLists [
      (with pkgs; [
        bat
        cht-sh
        colordiff
        curl
        exa
        file
        htop
        jq
        lazygit
        neofetch
        openssh
        spotify-tui
        subversion
        tree
        unzip
        wget
      ])
      (lib.lists.optionals cfg.devops.enable (with pkgs; [
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
      ]))
    ];
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.cli;
in
{
  options.myHome.cli = {
    enable = (lib.mkEnableOption "cli") // { default = true; };
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
    home.packages = with pkgs; [
      bat
      cht-sh
      colordiff
      curl
      exa
      file
      fzf
      htop
      jq
      neofetch
      openssh
      p7zip
      tree
      unzip
      wget
      xh
      yj
      yq
    ];
  };
}

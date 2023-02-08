{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.cli;
in
{
  imports = [ ./devops.nix ];
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
      act
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
      yj
      yq
    ];
  };
}

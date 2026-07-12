{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.cli;
in
{
  options.myHome.cli = {
    enable = (lib.mkEnableOption "cli") // { default = true; };
    personalGitEnable = (lib.mkEnableOption "personalGitEnable") // { default = true; };
    minimal = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      gh.enable = lib.mkDefault (!cfg.minimal);
      git = {
        enable = lib.mkDefault (!cfg.minimal);
        settings = {
          user = {
            name = lib.mkIf cfg.personalGitEnable "Michał Mieszczak";
            email = lib.mkIf cfg.personalGitEnable "michal@mieszczak.com.pl";
          };
          checkout.defaultRemote = "origin";
        };
      };
    };
    home.packages = with pkgs; [
      eza
      file
      openssh
      tree
    ] ++ (if cfg.minimal then [ ] else [
      curl
      fzf
      htop
      jq
      nix-tree
      p7zip
      ripgrep
      unzip
      wget
      yj
      yq
    ]);
  };
}

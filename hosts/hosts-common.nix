{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "pl_PL.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  users.users.longer = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.neovim = { enable = true; defaultEditor = true; };
  environment.systemPackages = with pkgs; [
    git
  ];

  system.stateVersion = "21.11";
}

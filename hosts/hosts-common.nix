{ config, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;
  nix = {
    package = pkgs.nix;
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

  users.defaultUserShell = pkgs.zsh;
  programs.neovim = { enable = true; defaultEditor = true; };
  environment = {
    systemPackages = with pkgs; [ git ];
    pathsToLink = [ "/share/zsh" ];
  };
}

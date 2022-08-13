{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unrar"
    "reaper"
    "spotify"
    "spotify-unwrapped"
    "steam"
    "steam-original"
    "steam-runtime"
  ];


  hardware.enableRedistributableFirmware = true;
  nix = {
    package = pkgs.unstable.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc.automatic = true;
  };

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "pl_PL.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;
  users.users.${config.mainUser}.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCLO8jWFPCx141QQyBBSGFSEY1iGwrcrb0NnNfjDHopx+FDPSo3d8Rat9sMqojL9o80frLxU/SpkC/9BddCu7dqlmPFEt2rNvzG2Evv+Epovr/hHD5EeJP7fNdW+FqoODIK9GOJLstc5h8m7LdMwEpI7FlSVRbhBFhiwwhdbIlGNnFogDggjc9WIux5oyzY6i3O/GNeP/G9Mwi8STGGKS0yuBVtVmsJ+zakrXWpSAhm4N0OSZzxUKGAzLWCs67VnF4VM+/nhCqro9jlpORDyM19AmMtAC/M2NI8T/Um0UaUm/I3wFkOCRqRdbNk6M6pCmTGm6jOszugNjb8zUH4lT1KfSZbo/GIO0Lyxi3bPCQFQLl0r6aVMn0AIOkkNmPg4LvVa7ux9FlaE1qjEoe6TtkZ2i50+4FWWS2ZcFJpiNDQ8crc4TNnrjeOkye4E//gw+6ki3UaTETR7ZwsnnjiTLFw2aJcP8BGOZBVvjmkKSIZ6cLhyo0rc+yamxcWaCup27g8xxLlD6CXDwmvRz04KyxUJf6eBGmX58d3m2zhbDC9pJXh0I5HtbOydTLgY7wDFnLx9p6yNPSLyD4jotKJdCH5IjFL1s41/YzpunkhNRyWvNCLUBS5xiE+4BmFcTFWsov1dwd3+uriR5/Q7iMCnvl2kadAkRcjCcLR3vJKNwfqQ== longer@mordor"
  ];
  programs.neovim = { enable = true; defaultEditor = true; };
  environment = {
    systemPackages = with pkgs; [
      git
      dnsutils
      pciutils
    ];
    pathsToLink = [ "/share/zsh" ];
  };
}

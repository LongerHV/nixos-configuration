{ inputs, config, pkgs, lib, ... }:
{
  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    time.timeZone = "Europe/Warsaw";
    i18n.defaultLocale = "pl_PL.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "pl";
    };

    nix = {
      package = pkgs.unstable.nix;
      extraOptions = ''
        experimental-features = nix-command flakes
      '' + lib.optionalString (config.age.secrets ? "extra_access_tokens") ''
        !include ${config.age.secrets.extra_access_tokens.path}
      '';
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        unstable.flake = inputs.nixpkgs-unstable;
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
        dates = "weekly";
      };
    };

    programs.neovim = {
      enable = lib.mkDefault true;
      defaultEditor = lib.mkDefault true;
    };

    environment = {
      systemPackages = with pkgs; [
        git
        dnsutils
        pciutils
      ];
      shells = [ pkgs.zsh ];
      pathsToLink = [ "/share/zsh" ];
    };
  };
}

{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./gaming.nix
    ./gnome.nix
    ./user.nix
  ];
  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.tmpOnTmpfs = lib.mkDefault true;
    zramSwap.enable = lib.mkDefault true;

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
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      gc = {
        automatic = lib.mkDefault true;
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

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

    time.timeZone = lib.mkDefault "Europe/Warsaw";
    i18n.defaultLocale = lib.mkDefault "pl_PL.UTF-8";
    console = {
      font = lib.mkDefault "Lat2-Terminus16";
      keyMap = lib.mkDefault "pl";
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
        options = lib.mkDefault "--delete-older-than 14d";
        dates = lib.mkDefault "weekly";
      };
      settings = {
        auto-optimise-store = lib.mkDefault true;
      };
    };

    services = {
      openssh.passwordAuthentication = lib.mkDefault false;
    };

    environment = {
      systemPackages = with pkgs; [
        agenix
        git
        dnsutils
        pciutils
      ];
      shells = [ pkgs.zsh ];
      pathsToLink = [ "/share/zsh" ];
    };
  };
}

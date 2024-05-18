{ inputs, overlays, config, lib, pkgs, ... }:

let
  cfg = config.mySystem;
  substituters = {
    nasgul = {
      url = "https://cache.local.longerhv.xyz/";
      key = "cache.local.longerhv.xyz:ioE/YEOpla3uyof/kZQG+gNKgeBAhOMWh+riRAEzKDA=";
    };
    mordor = {
      url = "http://mordor.lan:5000";
      key = "mordor.lan:fY4rXQ7QqtaxsokDAA57U0kuXvlo9pzn3XgLs79TZX4";
    };
  };
in
{
  imports = [
    ./android.nix
    ./gaming.nix
    ./gnome.nix
    ./user.nix
    ./virt.nix
  ];

  options.mySystem = with lib; {
    nix.substituters = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.tmp.useTmpfs = lib.mkDefault true;
    zramSwap.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault "Europe/Warsaw";
    i18n.defaultLocale = lib.mkDefault "pl_PL.UTF-8";
    console = {
      font = lib.mkDefault "Lat2-Terminus16";
      keyMap = lib.mkDefault "pl";
    };

    nixpkgs = {
      inherit overlays;
      config.allowUnfree = true;
    };
    nix = {
      package = pkgs.nix;
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
        substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
        trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
      };
    };

    services.openssh = with lib; {
      settings.PasswordAuthentication = mkDefault false;
      settings.PermitRootLogin = mkDefault "no";
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

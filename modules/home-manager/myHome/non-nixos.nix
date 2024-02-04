{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.myHome.nonNixos;
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
  options.myHome.nonNixos = with lib; {
    enable = mkEnableOption "nonNixos";
    nix.substituters = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.packages = [
      pkgs.hostname
      config.nix.package # This must be here, enable option below does not ensure that nix is available in path
      pkgs.nixgl.auto.nixGLDefault
    ];

    nixpkgs.overlays = builtins.attrValues outputs.overlays;
    nixpkgs.config.allowUnfree = true;
    nix = {
      enable = true;
      package = pkgs.nix;
      extraOptions = ''
        experimental-features = nix-command flakes
        !include ./extra.conf
      '';
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      settings = lib.mkMerge [
        {
          nix-path = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
          substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
          trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
        }
        {
          trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
          substituters = lib.mkAfter [ "https://cache.nixos.org/" ];
        }
      ];
    };
    programs.home-manager.enable = true;
  };
}

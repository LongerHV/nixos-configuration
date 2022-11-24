{ inputs, config, lib, pkgs, ... }:

{
  options.nonNixos.enable = lib.mkEnableOption "nonNixos";
  config = lib.mkIf config.nonNixos.enable {
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.packages =  [
      pkgs.hostname
      config.nix.package # This must be here, enable option below does not ensure that nix is available in path
    ];

    nix = {
      enable = true;
      package = pkgs.unstable.nix;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      settings = {
        nix-path = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      };
    };
    programs.home-manager.enable = true;
  };
}

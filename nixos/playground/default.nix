{ config, lib, ... }:

{
  imports = [ ./playground.nix ];
  boot.isContainer = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking = {
    hostName = "playground";
    useDHCP = false;
    useHostResolvConf = false;
    resolvconf.enable = true;
    resolvconf.extraConfig = ''
      resolv_conf_local_only=NO
      name_server_blacklist=127.0.0.1
      name_servers=1.1.1.1
    '';
  };
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "22.05";
  nix.gc.automatic = false;

  mySystem.home-manager.enable = false;

  # Workaround for broken home-manager
  systemd.tmpfiles.rules = [
    "d /nix/var/nix/gcroots/per-user/${config.mySystem.user} - ${config.mySystem.user} - - -"
    "d /nix/var/nix/profiles/per-user/${config.mySystem.user} - ${config.mySystem.user} - - -"
  ];
}

{ config, ... }:

{
  boot.isContainer = true;
  networking.hostName = "playground";
  networking.useDHCP = false;
  networking.useHostResolvConf = false;
  networking.resolvconf.enable = true;
  networking.resolvconf.extraConfig = ''
    resolv_conf_local_only=NO
    name_server_blacklist=127.0.0.1
    name_servers=192.168.1.243
  '';
  security.sudo.wheelNeedsPassword = false;
  home-manager.users."${config.mainUser}" = import ../../home-manager;
  system.stateVersion = "22.05";
  nix.gc.automatic = false;

  # Workaround for broken home-manager
  systemd.tmpfiles.rules = [
    "d /nix/var/nix/gcroots/per-user/${config.mainUser} - ${config.mainUser} - - -"
    "d /nix/var/nix/profiles/per-user/${config.mainUser} - ${config.mainUser} - - -"
  ];
}

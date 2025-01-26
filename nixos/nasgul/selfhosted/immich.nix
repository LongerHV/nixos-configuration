{ config, ... }:

{
  homelab.traefik.services.immich.port = config.services.immich.port;
  services.immich = {
    enable = true;
    mediaLocation = "${config.homelab.storage}/immich";
  };
  systemd.tmpfiles.rules = [
    "d ${config.homelab.storage}/immich 750 ${config.services.immich.user} ${config.services.immich.group} - -"
  ];
}

{ config, ... }:

{
  virtualisation.oci-containers.containers.wger = {
    image = "wger/demo:2.1-dev";
    environment = {
      TZ = "${config.time.timeZone}";
    };
    volumes = [
      "/home/wger/db"
    ];
    extraOptions = [
      "--label"
      "traefik.http.routers.wger.rule=Host(`wger.local.${config.myDomain}`)"
      "--label"
      "traefik.http.services.wger.loadBalancer.server.port=80"
    ];
  };
}

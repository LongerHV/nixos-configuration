{ config, pkgs, ... }:

let
  imageName = "ghcr.io/community-valheim-tools/valheim-server";
  imageTag = "1.2.0";
  valheimPlusTag = "0.10.1.1";

  uid = 1500;
  gid = 1500;
  stateDir = "/var/lib/valheim";
  image = pkgs.dockerTools.pullImage {
    inherit imageName;
    imageDigest = "sha256:138c6f10759e8342309cfefe0b191221a956771ada1ea87157013d62e2befa19";
    hash = "sha256-xW05QZJ6DEWHAV4OFS5zMvqwds++asUjaoD46j+7ELA=";
    finalImageName = imageName;
    finalImageTag = imageTag;
  };
in
{
  users.users = {
    "${config.mySystem.user}".extraGroups = [ "valheim" ];
    valheim = {
      isSystemUser = true;
      createHome = true;
      home = stateDir;
      homeMode = "0770";
      description = "Valheim Game Server User";
      group = "valheim";
      inherit uid;
    };
  };
  users.groups.valheim = {
    inherit gid;
  };
  virtualisation.oci-containers.containers.valheim = {
    image = "${imageName}:${imageTag}";
    imageFile = image;
    autoStart = true;
    autoRemoveOnStop = false;
    ports = [
      "2456-2457:2456-2457/udp"
      "127.0.0.1:9001:9001/tcp"
    ];
    environment = {
      WORLD_NAME = "TrzejBracia";
      SERVER_NAME = "TrzejBracia";
      SERVER_PUBLIC = "false";
      SUPERVISOR_HTTP = "true";
      VALHEIM_PLUS = "true";
      VALHEIM_PLUS_RELEASE = "tags/${valheimPlusTag}";
      PERMISSIONS_UMASK = "002";
      TZ = config.time.timeZone;
      PUID = toString uid;
      PGID = toString gid;
    };
    environmentFiles = [ config.age.secrets.valheim_environment.path ];
    volumes = [
      "${stateDir}/config:/config"
      "${stateDir}/data:/opt/valheim"
      "${./valheim_plus.cfg}:/config/valheimplus/valheim_plus.cfg:ro"
    ];
    capabilities.SYS_NICE = true;
  };
  networking.firewall.allowedUDPPorts = [ 2456 2457 ];
  age.secrets.valheim_environment = {
    file = ../../../secrets/valheim_environment.age;
    owner = "valheim";
    group = "valheim";
    mode = "0400";
  };
}

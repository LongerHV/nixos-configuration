{ config, ... }:

let
  homeDir = "/var/lib/lldap";
  uid = 981;
  gid = 977;
  tag = "v0.4";
in
{
  users = {
    users.lldap = {
      inherit uid;
      group = "lldap";
      isSystemUser = true;
      home = homeDir;
      createHome = true;
    };
    groups.lldap = {
      inherit gid;
    };
  };

  virtualisation.oci-containers.containers.lldap = {
    image = "nitnelave/lldap:${tag}";
    environment = {
      TZ = "${config.time.timeZone}";
      # UID = builtins.toString uid;
      # GID = builtins.toString gid;
    };
    user = "${builtins.toString uid}:${builtins.toString gid}";
    volumes = [
      "${homeDir}:/data"
    ];
    extraOptions = [
      "--network=host"
      "--label"
      "traefik.http.routers.ldap.rule=Host(`ldap.local.${config.myDomain}`)"
      "--label"
      "traefik.http.services.ldap.loadBalancer.server.port=17170"
    ];
  };
}

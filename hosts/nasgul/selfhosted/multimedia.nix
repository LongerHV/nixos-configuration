{ config, ... }:

{
  users.groups.multimedia = { members = [ config.mainUser ]; };
  services = {
    jellyfin = { enable = true; group = "multimedia"; };
    sonarr = { enable = true; group = "multimedia"; };
    radarr = { enable = true; group = "multimedia"; };
    bazarr = { enable = true; group = "multimedia"; };
    prowlarr = { enable = true; };
    transmission = {
      enable = true;
      group = "multimedia";
      home = "/chonk/media/torrent";
      downloadDirPermissions = "775";
      settings = {
        umask = 2;
        rpc-authentication-required = false;
        rpc-host-whitelist-enabled = true;
        rpc-host-whitelist = "transmission.${config.myDomain}";
      };
    };
  };
}

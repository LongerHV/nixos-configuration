{ config, ... }:

let
  domain = "matrix.${config.homelab.domain}";
  port = 6167;
in
{
  age.secrets.tuwunel_registration_token = {
    file = ../../../secrets/nasgul_tuwunel_registration_token.age;
    owner = "tuwunel";
  };

  homelab.traefik.services.matrix = { inherit port; };

  services.matrix-tuwunel = {
    enable = true;
    settings.global = {
      server_name = domain;
      address = [ "127.0.0.1" ];
      port = [ port ];
      # Private server for the admin and the Hermes bot, LAN/VPN only.
      allow_federation = false;
      trusted_servers = [ ];
      allow_registration = true;
      registration_token_file = config.age.secrets.tuwunel_registration_token.path;
      well_known.client = "https://${domain}";
    };
  };

  # RocksDB is not copied live; stop tuwunel for the snapshot.
  homelab.backups.services.matrix = {
    backupPrepareCommand = "systemctl stop tuwunel.service";
    backupCleanupCommand = "systemctl start tuwunel.service";
    paths = [ "/var/lib/private/tuwunel" ];
  };
}

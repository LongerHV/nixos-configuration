{ config, lib, pkgs, ... }:

let
  hl = config.homelab;
  url = "https://n8n.${hl.domain}/";
  port = lib.toInt config.services.n8n.environment.N8N_PORT;
in
{
  config = lib.mkMerge [
    {
      homelab.traefik.services.n8n = { inherit port; };

      services = {
        n8n = {
          enable = true;
          environment = {
            N8N_LISTEN_ADDRESS = "127.0.0.1";
            N8N_HOST = "n8n.${hl.domain}";
            N8N_PROTOCOL = "https";
            N8N_EDITOR_BASE_URL = url;
            WEBHOOK_URL = url;
            N8N_PROXY_HOPS = 1;
            # Peer authentication over the unix socket; DynamicUser is named after the unit.
            DB_TYPE = "postgresdb";
            DB_POSTGRESDB_HOST = "/run/postgresql";
            DB_POSTGRESDB_DATABASE = "n8n";
            DB_POSTGRESDB_USER = "n8n";
          };
        };

        postgresql = {
          ensureDatabases = [ "n8n" ];
          ensureUsers = [{
            name = "n8n";
            ensureDBOwnership = true;
          }];
        };
      };

      systemd.services.n8n = {
        after = [ "postgresql.service" ];
        requires = [ "postgresql.service" ];
      };
    }

    (lib.mkIf hl.backups.enable {
      homelab.backups.services.n8n = {
        backupPrepareCommand = ''
          ${pkgs.util-linux}/bin/runuser -u ${config.services.postgresql.superUser} -- ${config.services.postgresql.package}/bin/pg_dump --clean --if-exists --dbname=n8n > /tmp/n8n-database.sql
        '';
        backupCleanupCommand = ''
          rm -f /tmp/n8n-database.sql
        '';
        paths = [
          # Holds the auto-generated credentials encryption key (.n8n/config).
          "/var/lib/private/n8n"
          "/tmp/n8n-database.sql"
        ];
      };
    })
  ];
}

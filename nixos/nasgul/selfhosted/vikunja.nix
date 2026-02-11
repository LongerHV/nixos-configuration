{ config, lib, pkgs, ... }:

let
  hl = config.homelab;
  cfg = config.services.vikunja;
  port = 3456;
in
{
  config = lib.mkMerge [
    {
      homelab.traefik.services.vikunja = { inherit port; };

      services.vikunja = {
        enable = true;
        package = pkgs.unstable.vikunja;
        inherit port;
        frontendScheme = "https";
        frontendHostname = "vikunja.${hl.domain}";
        environmentFiles = [ config.age.secrets.vikunja_environment.path ];
        database = {
          type = "postgres";
          host = "/run/postgresql";
          user = "vikunja";
          database = "vikunja";
        };
        settings = {
          service = {
            enableregistration = false;
            # v1.0.0 renamed frontendurl to publicurl; the stable module still
            # generates frontendurl, which is silently ignored by v1.0.0.
            publicurl = "https://vikunja.${hl.domain}/";
          };
          auth = {
            local.enabled = false;
            openid = {
              enabled = true;
              providers.authelia = {
                name = "Authelia";
                authurl = "https://auth.${hl.domain}";
                clientid = "vikunja";
              };
            };
          };
        };
      };

      services.postgresql = {
        ensureDatabases = [ "vikunja" ];
        ensureUsers = [{
          name = "vikunja";
          ensureDBOwnership = true;
        }];
      };

      age.secrets.vikunja_environment.file = ../../../secrets/nasgul_vikunja_environment.age;
    }

    (lib.mkIf hl.backups.enable {
      homelab.backups.services.vikunja = {
        user = "vikunja";
        backupPrepareCommand = ''
          ${config.services.postgresql.package}/bin/pg_dump --clean --if-exists --dbname=vikunja > /tmp/vikunja-database.sql
        '';
        backupCleanupCommand = ''
          rm -f /tmp/vikunja-database.sql
        '';
        paths = [
          "${cfg.settings.files.basepath or "/var/lib/vikunja/files"}"
          "/tmp/vikunja-database.sql"
        ];
      };
    })
  ];
}

{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.gitea;
  inherit (config.services) gitea;
  redis = config.services.redis.servers."";
  repositoriesDir = "${config.homelab.storage}/repositories";
  domain = "gitea.local.${hl.domain}";
in
{
  options.homelab.gitea = {
    enable = lib.mkEnableOption "gitea";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      users.users."${gitea.user}".extraGroups = [ "redis" ];
      systemd.tmpfiles.rules = [
        "d ${repositoriesDir} 750 ${gitea.user} gitea - -"
      ];

      homelab = {
        mysql.enable = true;
        redis.enable = true;
        traefik = {
          enable = true;
          services.gitea = { port = gitea.httpPort; };
        };
      };

      services.mysql = {
        ensureDatabases = [ "gitea" ];
        ensureUsers = [
          {
            name = gitea.database.user;
            ensurePermissions = {
              "gitea.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };

      services.gitea = {
        enable = true;
        rootUrl = "https://${domain}";
        repositoryRoot = repositoriesDir;
        database = {
          type = "mysql";
          socket = "/run/mysqld/mysqld.sock";
        };
        settings = {
          session = {
            COOKIE_SECURE = true;
            DISABLE_REGISTRATION = true;
            PROVIDER = "db";
            PROVIDER_CONFIG = "";
          };
          cache = {
            ENABLED = true;
            ADAPTER = "redis";
            HOST = "network=unix,addr=${redis.unixSocket},db=1,pool_rize=100,idle_timeout=180";
          };
        };
      };
    }

    (lib.mkIf hl.backups.enable {
      users.users."${gitea.user}".extraGroups = [ "restic" ];
      security.sudo.extraRules = [{
        users = [ gitea.user ];
        commands = [
          { command = "/run/current-system/sw/bin/systemctl stop gitea.service"; options = [ "NOPASSWD" ]; }
          { command = "/run/current-system/sw/bin/systemctl start gitea.service"; options = [ "NOPASSWD" ]; }
        ];
      }];
      homelab.backups.services.gitea = {
        inherit (gitea) user;
        backupPrepareCommand = ''
          /run/wrappers/bin/sudo systemctl stop gitea.service
          ${hl.mysql.package}/bin/mysqldump --databases gitea > ${gitea.stateDir}/dump/gitea.sql
        '';
        backupCleanupCommand = ''
          /run/wrappers/bin/sudo systemctl start gitea.service
          rm ${gitea.stateDir}/dump/gitea.sql
        '';
        paths = [ repositoriesDir gitea.stateDir ];
      };
    })

    (lib.mkIf hl.monitoring.enable {
      homelab.monitoring.targets = [ domain ];
      services.gitea.settings.metrics.ENABLED = true;
      services.traefik.dynamicConfigOptions.http.routers.gitea-monitoring = {
        rule = "Host(`${domain}`) && Path(`/metrics`)";
        service = "gitea";
        middlewares = [ "localhost-only" ];
        entrypoints = if hl.traefik.cloudflareTLS.enable then "websecure" else "web";
      };
      networking.hosts."127.0.0.1" = [ domain ];
    })

    (lib.mkIf hl.mail.enable {
      users.users."${gitea.user}".extraGroups = [ "sendgrid" ];
      services.gitea.settings.mailer = {
        ENABLED = true;
        # Use PROTOCOL instead of MAILER_TYPE after 1.18
        MAILER_TYPE = "sendmail";
        SENDMAIL_PATH = hl.mail.sendmailPath;
        FROM = "gitea@${config.homelab.domain}";
      };
    })
  ]);
}

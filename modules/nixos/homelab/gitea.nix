{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.gitea;
  inherit (config.services) gitea;
  redis = config.services.redis.servers."";
  repositoriesDir = "${config.homelab.storage}/repositories";
  domain = "gitea.${hl.domain}";
in
{
  options.homelab.gitea = with lib; {
    enable = mkEnableOption "gitea";
    actions = {
      enable = mkEnableOption "actions";
      tokenFile = mkOption {
        type = types.str;
      };
    };
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
          services.gitea = { port = gitea.settings.server.HTTP_PORT; };
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
        repositoryRoot = repositoriesDir;
        database = {
          type = "mysql";
          socket = "/run/mysqld/mysqld.sock";
        };
        settings = {
          server = {
            ROOT_URL = "https://${domain}";
          };
          service = {
            DISABLE_REGISTRATION = true;
          };
          session = {
            COOKIE_SECURE = true;
            PROVIDER = "db";
            PROVIDER_CONFIG = "";
            SESSION_LIFE_TIME = 60 * 60 * 24 * 7;
          };
          cache = {
            ENABLED = true;
            ADAPTER = "redis";
            HOST = "network=unix,addr=${redis.unixSocket},db=1,pool_rize=100,idle_timeout=180";
          };
          actions.ENABLED = true;
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
      services.prometheus.scrapeConfigs = [{
        job_name = "gitea";
        static_configs = [{ targets = [ domain ]; }];
      }];
      services.grafana.provision.dashboards.settings.providers = [{
        name = "gitea";
        options.path = ./dashboards/gitea.json;
      }];
      services.gitea.settings.metrics.ENABLED = true;
      homelab.traefik.metrics.gitea.service = "gitea";
      networking.hosts."127.0.0.1" = [ domain ];
    })

    (lib.mkIf hl.mail.enable {
      users.users."${gitea.user}".extraGroups = [ "sendgrid" ];
      services.gitea.settings.mailer = {
        ENABLED = true;
        PROTOCOL = "sendmail";
        SENDMAIL_PATH = hl.mail.sendmailPath;
        FROM = "gitea@${config.homelab.domain}";
      };
    })

    (lib.mkIf hl.gitea.actions.enable {
      services.gitea-actions-runner.instances."${config.networking.hostName}" = {
        enable = true;
        name = config.networking.hostName;
        url = gitea.settings.server.ROOT_URL;
        inherit (hl.gitea.actions) tokenFile;
        labels = [
          "debian-latest:docker://node:18-bullseye"
        ];
      };
    })
  ]);
}

{ config, lib, ... }:

let
  hl = config.homelab;
  cfg = hl.gitea;
  inherit (config.services) gitea;
  redis = config.services.redis.servers."";
  repositoriesDir = "${config.homelab.storage}/repositories";
in
{
  options.homelab.gitea = {
    enable = lib.mkEnableOption "gitea";
  };
  config = lib.mkIf cfg.enable {
    users.users."${gitea.user}".extraGroups = builtins.concatLists [
      [ "redis" ]
      (lib.lists.optional hl.mail.enable "sendgrid")
    ];

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

      backups.services.gitea = {
        backupPrepareCommand = ''
          systemctl stop gitea.service
          ${hl.mysql.package}/bin/mysqldump --databases gitea > ${gitea.stateDir}/dump/gitea.sql
        '';
        backupCleanupCommand = ''
          systemctl start gitea.service
          rm ${gitea.stateDir}/dump/gitea.sql
        '';
        paths = [ repositoriesDir gitea.stateDir ];
      };
    };

    services.mysql = lib.mkIf hl.mysql.enable {
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
      rootUrl = "https://gitea.local.${config.homelab.domain}";
      repositoryRoot = repositoriesDir;
      database = {
        type = "mysql";
        socket = "/run/mysqld/mysqld.sock";
      };
      settings = {
        session = {
          COOKIE_SECURE = true;
          DISABLE_REGISTRATION = true;
        } // (lib.attrsets.optionalAttrs hl.mysql.enable {
          PROVIDER = "db";
          PROVIDER_CONFIG = "";
        });
        cache = {
          ENABLED = true;
          ADAPTER = "redis";
          HOST = "network=unix,addr=${redis.unixSocket},db=1,pool_rize=100,idle_timeout=180";
        };
        mailer = lib.mkIf hl.mail.enable {
          ENABLED = true;
          # Use PROTOCOL instead of MAILER_TYPE after 1.18
          MAILER_TYPE = "sendmail";
          SENDMAIL_PATH = hl.mail.sendmailPath;
          FROM = "gitea@${config.homelab.domain}";
        };
      };
    };
  };
}

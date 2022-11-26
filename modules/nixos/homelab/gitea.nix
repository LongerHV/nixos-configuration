{ config, lib, ... }:

let
  cfg = config.homelab.gitea;
  inherit (config.homelab) redis mysql mail;
  giteaService = config.services.gitea;
  redisService = config.services.redis.servers."";
in
{
  options.homelab.gitea = {
    enable = lib.mkEnableOption "gitea";
  };
  config = lib.mkIf cfg.enable {
    users.users."${config.mySystem.user}".extraGroups = [ "gitea" ];
    users.users."${giteaService.user}".extraGroups = builtins.concatLists [
      (lib.lists.optional redis.enable "redis")
      (lib.lists.optional mail.enable "sendgrid")
    ];

    services.mysql = {
      ensureDatabases = [ "gitea" ];
      ensureUsers = [
        {
          name = config.services.gitea.database.user;
          ensurePermissions = {
            "gitea.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    services.gitea = {
      enable = true;
      rootUrl = "https://gitea.local.${config.homelab.domain}";
      repositoryRoot = "${config.homelab.storage}/repositories";
      database = lib.mkIf mysql.enable {
        type = "mysql";
        socket = "/run/mysqld/mysqld.sock";
      };
      settings = {
        session = {
          COOKIE_SECURE = true;
          DISABLE_REGISTRATION = true;
        } // (lib.attrsets.optionalAttrs mysql.enable {
          PROVIDER = "db";
          PROVIDER_CONFIG = "";
        });
        cache = lib.mkIf redis.enable {
          ENABLED = true;
          ADAPTER = "redis";
          HOST = "network=unix,addr=${redisService.unixSocket},db=1,pool_rize=100,idle_timeout=180";
        };
        mailer = lib.mkIf mail.enable {
          ENABLED = true;
          # Use PROTOCOL instead of MAILER_TYPE after 1.18
          MAILER_TYPE = "sendmail";
          SENDMAIL_PATH = config.homelab.mail.sendmailPath;
          FROM = "gitea@${config.homelab.domain}";
        };
      };
    };
  };
}

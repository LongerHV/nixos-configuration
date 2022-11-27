{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.mail;
in
{
  options.homelab.mail = {
    enable = lib.mkEnableOption "mail";
    sendmailPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.security.wrapperDir}/sendmail";
      readOnly = true;
      description = ''
        Path to a sendmail executable. Do not override.
      '';
    };
    smtp.host = lib.mkOption {
      type = lib.types.str;
    };
    smtp.port = lib.mkOption {
      type = lib.types.int;
    };
    smtp.user = lib.mkOption {
      type = lib.types.str;
    };
    smtp.passFile = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.msmtp = {
      enable = true;
      accounts.default = {
        auth = true;
        tls = true;
        tls_starttls = false;
        inherit (cfg.smtp) host port user;
        passwordeval = "${pkgs.coreutils}/bin/cat ${cfg.smtp.passFile}";
      };
    };
  };
}

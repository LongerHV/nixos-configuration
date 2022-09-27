{ config, pkgs, ... }:

{
  users = {
    users.sendgrid = {
      group = "sendgrid";
      isSystemUser = true;
      createHome = false;
    };
    groups.sendgrid = { };
  };
  age.secrets = {
    sendgrid_token = {
      file = ../../../secrets/nasgul_sendgrid_token.age;
      owner = "sendgrid";
      mode = "0440";
    };
  };
  programs.msmtp = {
    enable = true;
    accounts.default = {
      auth = true;
      tls = true;
      tls_starttls = false;
      host = "smtp.sendgrid.net";
      port = 465;
      user = "apikey";
      passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.sendgrid_token.path}";
    };
  };
}

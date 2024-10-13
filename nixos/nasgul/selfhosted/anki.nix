{ config, ... }:

{
  homelab.traefik.services.anki.port = config.services.anki-sync-server.port;
  services.anki-sync-server = {
    enable = true;
    address = "127.0.0.1";
    users = [{
      username = config.mySystem.user;
      passwordFile = config.age.secrets.anki_password.path;
    }];
  };
  age = {
    secrets = {
      anki_password = {
        file = ../../../secrets/nasgul_anki_password.age;
        mode = "0440";
      };
    };
  };
}

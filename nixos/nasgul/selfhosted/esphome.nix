{ config, lib, ... }:

{
  homelab.traefik.services.esphome.port = config.services.esphome.port;
  services.esphome = {
    enable = true;
  };
  systemd.services.esphome.serviceConfig = {
    ProtectSystem = lib.mkForce "off";
    DynamicUser = lib.mkForce "false";
    User = "esphome";
    Group = "esphome";
  };
  users.users.esphome = {
    isSystemUser = true;
    home = "/var/lib/esphome";
    group = "esphome";
  };
  users.groups.esphome = { };
}

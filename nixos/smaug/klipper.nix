{ config, ... }:

{
  security.polkit.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 config.services.moonraker.port ];
  users = {
    users.klipper = {
      group = "klipper";
      isSystemUser = true;
    };
    users.moonraker.extraGroups = [ "klipper" ];
    groups.klipper = { };
  };
  services = {
    nginx.clientMaxBodySize = "100M";
    fluidd.enable = true;
    moonraker = {
      enable = true;
      address = "0.0.0.0";
      allowSystemControl = true;
      settings.authorization = {
        force_logins = true;
        trusted_clients = [ "10.69.1.0/24" "127.0.0.1/32" ];
        cors_domains = [ "*.lan" ];
      };
    };
    klipper =
      let
        serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
      in
      {
        enable = true;
        user = "klipper";
        group = "klipper";
        firmwares.mcu = {
          enable = true;
          configFile = ./config;
          inherit serial;
        };
        mutableConfig = true;
        configFile = ./printer.cfg;
      };
  };
}

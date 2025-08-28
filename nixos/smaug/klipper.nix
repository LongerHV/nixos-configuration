{ config, ... }:

let
  serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
in
{
  security.polkit.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 config.services.moonraker.port ];
  services = {
    nginx.clientMaxBodySize = "100M";
    fluidd.enable = true;
    moonraker = {
      enable = true;
      address = "0.0.0.0";
      allowSystemControl = true;
      settings.authorization = {
        force_logins = true;
        trusted_clients = [ "10.123.1.0/24" "127.0.0.1/32" ];
        cors_domains = [ "*.lan" ];
      };
    };
    klipper = {
      enable = true;
      inherit (config.services.moonraker) user group;
      firmwares.mcu = {
        enable = true;
        configFile = ./config;
        inherit serial;
      };
      mutableConfig = true;
      mutableConfigFolder = config.services.moonraker.stateDir + "/config";
      configFile = ./printer.cfg;
    };
  };
}

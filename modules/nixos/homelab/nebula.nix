{ config, lib, ... }:

let
  cfg = config.homelab.nebula;
  hostname = config.networking.hostName;
in
{
  options.homelab.nebula = with lib; {
    enable = mkEnableOption "nebula";
    isLighthouse = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.nebula_key = {
      file = ../../../nebula/${hostname}.key.age;
      owner = "nebula-homelab";
    };

    services = {
      nebula-lighthouse-service = {
        enable = cfg.isLighthouse;
      };
      nebula.networks.homelab = {
        enable = true;
        ca = ../../../nebula/ca.crt;
        cert = ../../../nebula/${hostname}.crt;
        key = config.age.secrets.nebula_key.path;
        isLighthouse = cfg.isLighthouse;
        lighthouses = [ "10.42.0.1" ];
        staticHostMap."10.42.0.1" = [ "nasgul.lan:4242" ];
        firewall = {
          inbound = [{ host = "any"; proto = "icmp"; port = "any"; }];
          outbound = [{ host = "any"; proto = "icmp"; port = "any"; }];
        };
      };
    };
  };
}

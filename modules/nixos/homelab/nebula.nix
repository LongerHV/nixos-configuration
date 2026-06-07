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
    hosts = mkOption {
      readOnly = true;
      default = {
        nasgul = "10.42.0.1";
        mordor = "10.42.0.2";
        palantir = "10.42.0.3";
        anarion = "10.42.0.4";
        isildur = "10.42.0.5";
      };
    };
    address = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    homelab.nebula.address = lib.getAttr hostname cfg.hosts;
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
        inherit (cfg) isLighthouse;
        lighthouses = [ (lib.getAttr "nasgul" cfg.hosts) ];
        staticHostMap."${lib.getAttr "nasgul" cfg.hosts}" = [ "nasgul.lan:4242" ];
        firewall = {
          inbound = [{ host = "any"; proto = "icmp"; port = "any"; }];
          outbound = [{ proto = "any"; port = "any"; host = "any"; }];
        };
      };
    };
  };
}

{ config, lib, ... }:

let
  redis = config.services.redis.servers."";
  inherit (config.services) blocky;
in
{
  imports = [ ./redis.nix ];

  networking = {
    nameservers = [ "127.0.0.1" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    firewall = {
      allowedTCPPorts = [
        53
      ];
      allowedUDPPorts = [
        53
      ];
    };
  };

  services.blocky = {
    enable = true;
    settings = {
      port = 53;
      # Cloudflare upstream DNS servers (maybe change to unbound?)
      upstream.default = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      # Reverse lookup (does this even work?)
      clientLookup = {
        upstream = "192.168.1.1";
      };
      # My custom entries for local network
      customDNS = {
        customTTL = "1h";
        mapping = {
          "local.${config.myDomain}" = "192.168.1.243";
        };
      };
      # Redirect all .lan queries to the router
      conditional = {
        mapping = {
          lan = "192.168.1.1";
        };
      };
      redis = {
        address = redis.unixSocket;
        database = 2;
        required = true;
      };
    };
  };

  users.users.blocky = {
    group = "blocky";
    extraGroups = [ "redis" ];
    createHome = false;
    isSystemUser = true;
  };
  users.groups.blocky = { };

  systemd.services.blocky = {
    after = [ "redis.service" ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "blocky";
      Group = "blocky";
    };
  };
}

{ config, lib, pkgs, ... }:

let
  redis = config.services.redis.servers."";
  util = pkgs.callPackage ./util.nix { inherit config; };
in
{
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

  services.traefik.dynamicConfigOptions.http = {
      routers.blocky_router = util.traefik_router { subdomain = "blocky"; middlewares = [ "authelia" ]; };
      services.blocky_service = util.traefik_service { port = 4000; };
  };

  services.blocky = {
    enable = true;
    settings = {
      port = 53;
      httpPort = 4000;
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
          "xerox.local" = "192.168.1.197";
        };
      };
      # Redirect all .lan queries to the router
      conditional = {
        mapping = {
          lan = "192.168.1.1";
        };
      };
      blocking = {
        blockType = "zeroIP";
        blackLists = {
          ads = [
            # "https://adaway.org/hosts.txt"
            # "https://v.firebog.net/hosts/AdguardDNS.txt"
            # "https://v.firebog.net/hosts/Admiral.txt"
            "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
            # "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            # "https://v.firebog.net/hosts/Easylist.txt"
            # "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
            "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
          ];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
          "192.168.1.165/32" = [ ];
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

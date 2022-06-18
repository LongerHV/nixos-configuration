{ config, ... }:

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

  services.blocky = {
    enable = true;
    settings = {
      port = 53;
      # Cloudflare and Quad9 upstream DNS servers (maybe change to unbound?)
      upstream.default = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      # Reverse lookup (does this even work?)
      clientLookup = {
        upstream = "192.168.1.1";
      };
      # My custom entries for local network
      customDNS = {
        customTTL = "1h";
        mapping = {
          "${config.myDomain}" = "192.168.1.243";
        };
      };
      # Redirect all .lan queries to the router
      conditional = {
        mapping = {
          lan = "192.168.1.1";
        };
      };
    };
  };
}

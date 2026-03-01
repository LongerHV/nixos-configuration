{
  networking = {
    hostName = "nasgul";
    hostId = "48392063";
    usePredictableInterfaceNames = false;
    useNetworkd = true;
    dhcpcd.enable = false;
    nftables.enable = true;
    nat = {
      enable = true;
      externalInterface = "eth0";
    };
    iproute2.enable = true;
  };
  systemd.network = {
    enable = true;

    # IOT VLAN setup
    netdevs."20-vlan20" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan20";
      };
      vlanConfig.Id = 20;
    };

    networks = {
      "10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "yes";
        };
        dhcpV4Config.UseDNS = false; # Conflicts with Blocky DNS
        vlan = [ "vlan20" ];
      };
      "20-vlan20" = {
        matchConfig.Name = "vlan20";
        networkConfig = {
          DHCP = "yes";
        };
        dhcpV4Config = {
          UseDNS = false; # Don't override Blocky DNS
          UseRoutes = false;
        };
        # Permanent neighbor entries for the two OTBR border routers.
        # nasgul routes Thread prefix fd31:4b6b:8506:1::/64 via their link-locals
        # (learned via RA, proto ra). Without these, NDP for those next-hops goes
        # through the AP bridge multicast path — which fails due to the Linux 6.6.x
        # MLD querier bug (MDB entries expire, querier stays permanently silent).
        extraConfig = ''
          [Neighbor]
          Address=fe80::71a2:9a77:d1f2:f5db
          LinkLayerAddress=88:a2:9e:8a:a2:7a

          [Neighbor]
          Address=fe80::fc3a:e35f:472f:63bd
          LinkLayerAddress=88:a2:9e:8c:c8:0c
        '';
      };
    };
  };
  services.resolved.enable = false;
}

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
        # Permanent neighbour entries for the two OTBR border routers.
        # nasgul routes the Thread OMR prefix via their link-locals (learned via RA,
        # proto ra). The prefix itself is not stable across OTBR restarts, so it is
        # deliberately not hardcoded anywhere. Without these, NDP for those next-hops goes
        # through the AP bridge multicast path - see network-changes.md Problems 4 and 9.
        #
        # These are EUI-64 link-locals derived from each MAC
        # (88:a2:9e:XX:XX:XX -> fe80::8aa2:9eff:feXX:XXXX). They were previously
        # NetworkManager stable-privacy addresses; when addr-gen-mode changed to EUI-64
        # these entries silently went stale. Keep in sync with nixos/anarion/default.nix
        # and verify on each host with: ip -6 addr show wlan0 scope link
        extraConfig = ''
          # isildur
          [Neighbor]
          Address=fe80::8aa2:9eff:fe8a:a27a
          LinkLayerAddress=88:a2:9e:8a:a2:7a

          # anarion
          [Neighbor]
          Address=fe80::8aa2:9eff:fe8c:c80c
          LinkLayerAddress=88:a2:9e:8c:c8:0c
        '';
      };
    };
  };
  services.resolved.enable = false;
}

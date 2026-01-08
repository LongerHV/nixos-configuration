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
      };
    };
  };
  services.resolved.enable = false;
}

{
  networking = {
    hostName = "nasgul";
    hostId = "48392063";
    enableIPv6 = false;
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
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "yes";
      };
      dhcpV4Config.UseDNS = false; # Conflicts with Blocky DNS
    };
  };
  services.resolved.enable = false; # Conflicts with Blocky DNS
}

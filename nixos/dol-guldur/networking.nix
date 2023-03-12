{
  networking = {
    useNetworkd = true;
    enableIPv6 = false;
    dhcpcd.enable = false;
  };
  systemd.network.enable = true;
  services.resolved.enable = true;
}

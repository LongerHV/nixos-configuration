{
  networking = {
    useNetworkd = true;
    enableIPv6 = false;
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    wait-online.extraArgs = [ "--interface" "enp1s0" ];
  };
  services.resolved.enable = true;
}

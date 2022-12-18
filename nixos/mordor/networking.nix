_:

{
  networking = {
    useNetworkd = true;
    usePredictableInterfaceNames = false;
    networkmanager.enable = false;
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    wait-online.extraArgs = [ "--interface" "eth0" ];
  };
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS = 10.69.1.243
    '';
  };
}

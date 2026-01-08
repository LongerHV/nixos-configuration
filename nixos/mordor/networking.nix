{
  imports = [ ./vpn.nix ];

  networking = {
    useNetworkd = false;
    # enableIPv6 = false;
    # "Predictable" interface names are not that predictable lol
    usePredictableInterfaceNames = false;
    # NetworkManager is implicitly enabled by gnome
    networkmanager.enable = true;
    # DHCPCD is still the default on NixOS
    dhcpcd.enable = false;
  };
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS = 10.123.1.243
    '';
  };
}

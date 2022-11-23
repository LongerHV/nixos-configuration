_:

{
  networking = {
    hostName = "nasgul";
    hostId = "48392063";
    useDHCP = false;
    enableIPv6 = false;
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
    nat = {
      enable = true;
      externalInterface = "eth0";
    };
    iproute2.enable = true;
  };
}

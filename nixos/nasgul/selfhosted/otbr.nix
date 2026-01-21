{ config, ... }:

{
  services.otbr = {
    enable = true;
    rcpDevice = "/dev/serial/by-id/usb-Nordic_Semiconductor_nRF528xx_OpenThread_Device_E212FEDD5954-if00";
    infraInterface = "vlan20";
    storage = "${config.homelab.storage}/otbr";
  };
}

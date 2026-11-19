{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./klipper.nix
  ];

  mySystem.home-manager = {
    enable = true;
    home = ./home.nix;
  };

  homelab = {
    nebula.enable = true;
    monitoringTarget = {
      enable = true;
    };
  };

  boot = {
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  networking = {
    hostName = "smaug";
    useNetworkd = true;
    enableIPv6 = false;
    dhcpcd.enable = false;
    # DHCP on end0 and wlan0 comes from networking.useDHCP (networkd defaults)
    wireless = {
      enable = true;
      # Contains: psk_millennium_falcon=<passphrase>
      secretsFile = config.age.secrets.smaug_wifi.path;
      networks.MillenniumFalcon.pskRaw = "ext:psk_millennium_falcon";
    };
  };
  age.secrets.smaug_wifi = {
    file = ../../secrets/smaug_wifi.age;
    # wpa_supplicant runs unprivileged and reads the PSK at runtime
    owner = "wpa_supplicant";
  };
  systemd.network = {
    enable = true;
    # Online as soon as either ethernet or WiFi is up
    wait-online.anyInterface = true;
  };
  services.openssh.enable = true;

  # Free up to 1GiB whenever there is less than 100MiB left.
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-users = [ config.mySystem.user ];
  system.stateVersion = "22.11";
}

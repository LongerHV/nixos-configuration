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

  # Enable SPI0 with a spidev on CE0 (/dev/spidev0.0) for the ADXL345
  # accelerometer used by klipper's input shaper (via the host MCU).
  # Wiring: 3V3 pin 1, GND pin 6, MOSI pin 19, MISO pin 21, SCLK pin 23, CS pin 24
  hardware.deviceTree = {
    filter = "bcm2711-rpi-4-b.dtb";
    overlays = [{
      name = "spi0-spidev";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "brcm,bcm2711";
          fragment@0 {
            target = <&spi>;
            __overlay__ {
              status = "okay";
              pinctrl-names = "default";
              pinctrl-0 = <&spi0_gpio7>;
              /* CE0 = GPIO8, active low. Without explicit cs-gpios the
                 driver looks up native CS on a "pinctrl-bcm2835" gpiochip,
                 which on BCM2711 is "pinctrl-bcm2711", so probing fails. */
              cs-gpios = <&gpio 8 1>;
              #address-cells = <1>;
              #size-cells = <0>;
              spidev@0 {
                /* any compatible from spidev's match table binds it */
                compatible = "rohm,dh2228fv";
                reg = <0>;
                spi-max-frequency = <5000000>;
              };
            };
          };
        };
      '';
    }];
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

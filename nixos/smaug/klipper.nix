{ config, pkgs, ... }:

let
  serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
  # Linux "host" MCU letting klipper use the Pi's GPIO/SPI/I2C.
  # Reference it in printer.cfg with:
  #   [mcu host]
  #   serial: /tmp/klipper_host_mcu
  hostMcuSerial = "/tmp/klipper_host_mcu";
  hostMcu = pkgs.klipper-firmware.override {
    klipper = config.services.klipper.package;
    mcu = "host";
    firmwareConfig = ./config-host;
  };
in
{
  security.polkit.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 config.services.moonraker.port ];
  services = {
    nginx.clientMaxBodySize = "100M";
    fluidd.enable = true;
    moonraker = {
      enable = true;
      address = "0.0.0.0";
      allowSystemControl = true;
      settings.authorization = {
        force_logins = true;
        trusted_clients = [ "10.123.1.0/24" "127.0.0.1/32" ];
        cors_domains = [ "*.lan" ];
      };
    };
    klipper = {
      enable = true;
      inherit (config.services.moonraker) user group;
      firmwares.mcu = {
        enable = true;
        configFile = ./config;
        inherit serial;
      };
      mutableConfig = true;
      configDir = config.services.moonraker.stateDir + "/config";
      configFile = ./printer.cfg;
    };
  };

  # Port of klipper's scripts/klipper-mcu.service
  systemd.services.klipper-mcu = {
    description = "Klipper Linux host MCU";
    documentation = [ "https://www.klipper3d.org/RPi_microcontroller.html" ];
    wantedBy = [ "multi-user.target" ];
    before = [ "klipper.service" ];
    environment.KLIPPER_HOST_MCU_SERIAL = hostMcuSerial;
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = true;
      ExecStart = "${hostMcu}/klipper.elf -r -I \${KLIPPER_HOST_MCU_SERIAL}";
      ExecStop = [
        "${pkgs.runtimeShell} -c 'echo FORCE_SHUTDOWN > \${KLIPPER_HOST_MCU_SERIAL}'"
        "${pkgs.coreutils}/bin/sleep 1"
      ];
      TimeoutStopSec = 2;
      Restart = "always";
      RestartSec = 5;
    };
  };

  # The host MCU pty is owned by root:tty with mode 0660
  systemd.services.klipper.serviceConfig.SupplementaryGroups = [ "tty" ];
}

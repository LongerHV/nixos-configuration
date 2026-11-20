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
  # Must match CONFIG_SERIAL_BAUD of both katapult and ./config
  baud = "250000";
  # Flash the MCU firmware built from ./config via the katapult bootloader.
  # Usage: klipper-flash-mcu [path/to/klipper.bin]
  klipperFlashMcu = pkgs.writeShellApplication {
    name = "klipper-flash-mcu";
    runtimeInputs = [ pkgs.katapult-flashtool pkgs.systemd ];
    text = ''
      if [ "$EUID" -ne 0 ]; then
        exec sudo "$0" "$@"
      fi
      firmware="''${1:-${config.services.klipper.firmwares.mcu.package}/klipper.bin}"
      [ -f "$firmware" ] || { echo "firmware not found: $firmware" >&2; exit 1; }

      echo "Stopping klipper"
      systemctl stop klipper.service
      trap 'echo "Starting klipper"; systemctl start klipper.service' EXIT

      echo "Requesting katapult bootloader"
      katapult-flashtool -d ${serial} -b ${baud} -r
      echo "Flashing $firmware"
      katapult-flashtool -d ${serial} -b ${baud} -f "$firmware"
    '';
  };
in
{
  security.polkit.enable = true;
  # Flash klipper over USB through the katapult bootloader (see README.md)
  environment.systemPackages = [ pkgs.katapult-flashtool klipperFlashMcu ];
  networking.firewall.allowedTCPPorts = [ 80 config.services.moonraker.port ];
  # Klipper exporter: probes moonraker on localhost (a trusted client, no API key),
  # scraped by prometheus on nasgul over nebula
  networking.firewall.interfaces."nebula.homelab".allowedTCPPorts = [
    config.services.prometheus.exporters.klipper.port
  ];
  services = {
    prometheus.exporters.klipper = {
      enable = true;
      listenAddress = config.homelab.nebula.address;
    };
    nebula.networks.homelab.firewall.inbound = [{
      proto = "tcp";
      inherit (config.services.prometheus.exporters.klipper) port;
      group = "prometheus";
    }];
    nginx.clientMaxBodySize = "100M";
    fluidd.enable = true;
    moonraker = {
      enable = true;
      # gpiod is needed by the gpio [power] device
      package = pkgs.moonraker.override { useGpiod = true; };
      address = "0.0.0.0";
      allowSystemControl = true;
      settings = {
        authorization = {
          force_logins = true;
          trusted_clients = [ "10.123.1.0/24" "127.0.0.1/32" ];
          cors_domains = [ "*.lan" ];
        };
        # Relay switching the 24V PSU, active-high on GPIO26 (header pin 37).
        # GPIO9-27 default to pull-down at boot, so the PSU stays off until
        # moonraker takes the pin (GPIO0-8 are pulled up and would switch it on).
        "power printer" = {
          type = "gpio";
          pin = "gpiochip0/gpio26";
          initial_state = "off";
          # cut power if Klipper hits an emergency shutdown
          off_when_shutdown = true;
          # can't switch it off by accident mid-print
          locked_while_printing = true;
          restart_klipper_when_powered = true;
          restart_delay = 3;
          # power on automatically when a job is queued
          on_when_job_queued = true;
        };
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

  # Let moonraker drive the PSU relay through /dev/gpiochip*
  users.groups.gpio = { };
  services.udev.extraRules = ''
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
  '';
  systemd.services.moonraker.serviceConfig.SupplementaryGroups = [ "gpio" ];
}

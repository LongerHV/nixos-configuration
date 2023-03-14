{ config, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 config.services.moonraker.port ];
  users = {
    users.klipper = {
      group = "klipper";
      isSystemUser = true;
    };
    groups.klipper = { };
  };
  services = {
    fluidd.enable = true;
    moonraker = {
      enable = true;
      group = "klipper";
      address = "0.0.0.0";
      settings.authorization = {
        force_logins = true;
        trusted_clients = [ "10.69.1.0/24" "127.0.0.1/32" ];
        cors_domains = [ "*.lan" ];
      };
    };
    klipper =
      let
        serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
      in
      {
        enable = true;
        user = "klipper";
        group = "klipper";
        firmwares.mcu = {
          enable = true;
          configFile = ./config;
          inherit serial;
        };
        mutableConfig = true;
        settings = {
          mcu = {
            inherit serial;
          };
          printer = {
            kinematics = "cartesian";
            max_velocity = 300;
            max_accel = 5000;
            max_z_velocity = 5;
            max_z_accel = 100;
          };
          fan.pin = "PA0";
          stepper_x = {
            step_pin = "PC2";
            dir_pin = "PB9";
            enable_pin = "!PC3";
            microsteps = 16;
            rotation_distance = 40;
            endstop_pin = "^PA5";
            position_endstop = 0;
            position_max = 235;
            homing_speed = 50;
          };
          stepper_y = {
            step_pin = "PB8";
            dir_pin = "PB7";
            enable_pin = "!PC3";
            microsteps = 16;
            rotation_distance = 40;
            endstop_pin = "^PA6";
            position_endstop = 0;
            position_max = 235;
            homing_speed = 50;
          };
          stepper_z = {
            step_pin = "PB6";
            dir_pin = "!PB5";
            enable_pin = "!PC3";
            microsteps = 16;
            rotation_distance = 8;
            endstop_pin = " probe:z_virtual_endstop";
            position_min = -2;
            position_max = 250;
          };
          bltouch = {
            sensor_pin = "^PB1";
            control_pin = "PB0";
            x_offset = -54;
            y_offset = -15;
            z_offset = 1.6;
            probe_with_touch_mode = true;
            stow_on_each_sample = false;
          };
          safe_z_home = {
            home_xy_position = "177, 125";
            speed = 50;
            z_hop = 10;
            z_hop_speed = 5;
          };
        };
      };
  };
}

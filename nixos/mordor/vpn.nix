{ config, ... }:

{
  age.secrets = {
    mullvad_priv_key = {
      file = ../../secrets/mordor_mullvad_priv_key.age;
      mode = "0440";
      owner = "root";
      group = "systemd-network";
    };
  };
  networking = {
    wg-quick.interfaces = {
      wg-pl = {
        address = [ "10.68.22.110/32" ];
        privateKeyFile = config.age.secrets.mullvad_priv_key.path;
        peers = [
          {
            publicKey = "fO4beJGkKZxosCZz1qunktieuPyzPnEVKVQNhzanjnA=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "45.134.212.66:51820";
            persistentKeepalive = 25;
          }
        ];
      };
      wg-us = {
        autostart = false;
        address = [ "10.68.22.110/32" ];
        privateKeyFile = config.age.secrets.mullvad_priv_key.path;
        peers = [
          {
            publicKey = "MRZsEblqO4wlq0WPnZgp5X9ex4Z2FHm9bljO/a/Mznk=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "68.235.43.106:51820";
            persistentKeepalive = 25;
          }
        ];
      };
      wg-jp = {
        autostart = false;
        address = [ "10.68.22.110/32" ];
        privateKeyFile = config.age.secrets.mullvad_priv_key.path;
        peers = [
          {
            publicKey = "4EhX6bW/gfcu75nPm9nyexX6cRZXN/RCt/TETfXF0jc=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "217.138.252.226:51820";
            persistentKeepalive = 25;
          }
        ];
      };
      wg-ch = {
        autostart = false;
        address = [ "10.68.22.110/32" ];
        privateKeyFile = config.age.secrets.mullvad_priv_key.path;
        peers = [
          {
            publicKey = "/iivwlyqWqxQ0BVWmJRhcXIFdJeo0WbHQ/hZwuXaN3g=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "193.32.127.66:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}

{ config, ... }:

let
  mkMullvadInterface = { autostart, publicKey, endpoint }: {
    inherit autostart;
    address = [ "10.68.22.110/32" ];
    privateKeyFile = config.age.secrets.mullvad_priv_key.path;
    peers = [{
      inherit publicKey endpoint;
      allowedIPs = [ "0.0.0.0/0" ];
      persistentKeepalive = 25;
    }];
  };
in
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
      wg-pl = mkMullvadInterface {
        autostart = true;
        publicKey = "fO4beJGkKZxosCZz1qunktieuPyzPnEVKVQNhzanjnA=";
        endpoint = "45.134.212.66:51820";
      };
      wg-us = mkMullvadInterface {
        autostart = false;
        publicKey = "MRZsEblqO4wlq0WPnZgp5X9ex4Z2FHm9bljO/a/Mznk=";
        endpoint = "68.235.43.106:51820";
      };
      wg-jp = mkMullvadInterface {
        autostart = false;
        publicKey = "4EhX6bW/gfcu75nPm9nyexX6cRZXN/RCt/TETfXF0jc=";
        endpoint = "217.138.252.226:51820";
      };
      wg-ch = mkMullvadInterface {
        autostart = false;
        publicKey = "/iivwlyqWqxQ0BVWmJRhcXIFdJeo0WbHQ/hZwuXaN3g=";
        endpoint = "193.32.127.66:51820";
      };
    };
  };
}

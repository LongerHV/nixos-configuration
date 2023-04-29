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
    firewall.checkReversePath = false;
    wg-quick.interfaces.wg0 = {
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
  };
}

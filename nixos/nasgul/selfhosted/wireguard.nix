{ config, ... }:

{
  networking = {
    # Dummy routing table to stop wireguard from routing all traffic
    iproute2.rttablesExtraConfig = ''
      200 vpn
    '';

    # Wireguard client
    firewall.checkReversePath = false;
    wg-quick.interfaces.wg1 = {
      table = "vpn";
      address = [ "10.64.25.31/32" ];
      privateKeyFile = config.age.secrets.mullvad_priv_key.path;
      peers = [
        {
          publicKey = "C3jAgPirUZG6sNYe4VuAgDEYunENUyG34X42y+SBngQ=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "193.32.127.69:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}

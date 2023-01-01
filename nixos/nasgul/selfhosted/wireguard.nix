{ config, pkgs, ... }:

{
  age.secrets.wireguard_priv_key.file = ../../../secrets/nasgul_wireguard_priv_key.age;
  age.secrets.mullvad_priv_key.file = ../../../secrets/nasgul_mullvad_priv_key.age;

  networking = {
    nat.internalInterfaces = [ "wg0" ];
    firewall.allowedUDPPorts = [ 51820 ];

    # Wireguard Server
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';
      privateKeyFile = config.age.secrets.wireguard_priv_key.path;
      # Server public keys RXBEMl98FGQ0M5L1RmIAidw5s1eeTQ534pTHYSGES3o=
      peers = [
        {
          # Mobile
          publicKey = "hL9VANFN7BItGrBVDT4nKpXhiyykyshvc0Zrk9bfWio=";
          allowedIPs = [ "10.100.0.2" ];
        }
        {
          # Golum
          publicKey = "K/OYE5QPSZammNgpwEXpAx2+KPkZGveuyNM13qvQU1Q=";
          allowedIPs = [ "10.100.0.3" ];
        }
        {
          # iPad
          publicKey = "KJ7qkIgdudj6bHdlcUAmSuGx74C7+sVSfBxPhwKVBRs=";
          allowedIPs = [ "10.100.0.4" ];
        }
        {
          # Dad
          publicKey = "QyRmx4PseUd5YXD9IDnh/6HYQCXiJ1NtxJlT2EnvTXw=";
          allowedIPs = [ "10.100.0.5" ];
        }
        {
          # ASUS
          publicKey = "PYHOfbbVxFBtJDI9PzKJaodItPBJe5KMzQV6QdgXD3c=";
          allowedIPs = [ "10.100.0.6" ];
        }

      ];
    };

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

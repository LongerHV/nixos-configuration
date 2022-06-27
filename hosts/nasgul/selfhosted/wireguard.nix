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
      ];
    };
  };
}

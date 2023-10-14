{ config, pkgs, ... }:

{
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
          # Honor
          publicKey = "hL9VANFN7BItGrBVDT4nKpXhiyykyshvc0Zrk9bfWio=";
          allowedIPs = [ "10.100.0.2" ];
        }
        {
          # FP4
          publicKey = "2wa5Xc6CWC3C1NoX1zp0aQwL5y0gfs4osI2xmcVqHFI=";
          allowedIPs = [ "10.100.0.3" ];
        }
        {
          # ASUS
          publicKey = "L5u6MTLLUK4dco1LmMR14VzaRVgW2PL0cCzFRnGsrjo=";
          allowedIPs = [ "10.100.0.4" ];
        }
        {
          # Bro phone
          publicKey = "2zjbNOtTjnAsez5erA0e4DNc4zd+i2CLTm0mCp4Otls=";
          allowedIPs = [ "10.100.0.5" ];
        }
        {
          # Bro PC
          publicKey = "G+C3TYE7mRU5YRk01lBQRbqTfrskokhLjIXU62XsdRw=";
          allowedIPs = [ "10.100.0.6" ];
        }
        {
          # iPad
          publicKey = "UxFk/HxDVKQDaByAIyXQMw7Ns6iqbKxVNmd/Ed/FfFM=";
          allowedIPs = [ "10.100.0.7" ];
        }
        {
          # iPhone
          publicKey = "uMk5rt9MiEodr9s+L7K/b4AB61c1qISWF4BK6UjtGRE=";
          allowedIPs = [ "10.100.0.8" ];
        }
        {
          # Dell
          publicKey = "1AHpaG+jDBUYqHto1whhHQHx51vf7kTIrxl6tAUewnk=";
          allowedIPs = [ "10.100.0.9" ];
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

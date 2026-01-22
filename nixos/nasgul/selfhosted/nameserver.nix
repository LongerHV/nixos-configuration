{ config, pkgs, ... }:

{
  services.blocky.settings = {
    # Reverse lookup (does this even work?)
    clientLookup = {
      upstream = "10.123.1.1";
    };
    # My custom entries for local network
    customDNS = {
      customTTL = "1h";
      zone = ''
        $ORIGIN ${config.homelab.domain}.
        @ 3600 CNAME nasgul.lan.
      '';
    };
    # Redirect all .lan queries to the router
    conditional = {
      mapping = {
        lan = "10.123.1.1";
      };
    };
    blocking = {
      blockType = "zeroIP";
      denylists = {
        ads = [
          "https://adaway.org/hosts.txt"
          "https://v.firebog.net/hosts/AdguardDNS.txt"
          "https://v.firebog.net/hosts/Admiral.txt"
          "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
          "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
          "https://v.firebog.net/hosts/Easylist.txt"
          "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
          "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
        ];
        telemetry = [
          "https://v.firebog.net/hosts/Easyprivacy.txt"
          "https://v.firebog.net/hosts/Prigent-Ads.txt"
          "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
          "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
          "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
        ];
      };
      allowlists = {
        ads = [
          (pkgs.writeText "allowlist.txt" ''
            piwik.pro
          '')
        ];
      };
      clientGroupsBlock = {
        default = [ "ads" "telemetry" ];
      };
    };
  };
}

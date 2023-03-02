{ config, lib, pkgs, ... }:

{
  services.blocky.settings = {
    # Reverse lookup (does this even work?)
    clientLookup = {
      upstream = "10.69.1.1";
    };
    # My custom entries for local network
    customDNS = {
      customTTL = "1h";
      mapping = {
        "local.${config.myDomain}" = "10.69.1.243";
      };
    };
    # Redirect all .lan queries to the router
    conditional = {
      mapping = {
        lan = "10.69.1.1";
      };
    };
    blocking = {
      blockType = "zeroIP";
      blackLists = {
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
      };
      clientGroupsBlock = {
        default = [ "ads" ];
        "10.69.1.165/32" = [ ];
      };
    };
  };
}

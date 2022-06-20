{ config, pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_106;
    dataDir = "/chonk/database";
  };
}

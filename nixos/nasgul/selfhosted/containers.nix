{ pkgs, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";

    extraOptions = "--firewall-backend=nftables";
    extraPackages = [ pkgs.nftables ];
  };
}

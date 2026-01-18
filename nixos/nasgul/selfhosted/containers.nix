{ pkgs, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";

    # Use Docker 29 for compatibility with  nftables
    package = pkgs.docker_29;
    extraOptions = "--firewall-backend=nftables";
    extraPackages = [ pkgs.nftables ];
  };
}

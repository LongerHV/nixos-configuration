{ config, pkgs, ... }:

{
  users.users."${config.mySystem.user}".extraGroups = [ "docker" ];
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "docker";
    docker = {
      enable = true;
      storageDriver = "zfs";
      extraOptions = "--firewall-backend=nftables";
      extraPackages = [ pkgs.nftables ];
    };
  };

  # Delete only the tables NixOS manages instead of `flush ruleset` on every
  # nftables reload. A full flush also wipes Docker's `docker-bridges` table,
  # which silently kills outbound NAT for every container until Docker happens
  # to reprogram that table again. Defaults to true here because stateVersion
  # predates 23.11.
  networking.nftables.flushRuleset = false;
}

{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };
}

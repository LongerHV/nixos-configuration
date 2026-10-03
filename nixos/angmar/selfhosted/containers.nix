{
  # Containers run rootless under their own users (podman.user), see valheim.nix.
  virtualisation.oci-containers.backend = "podman";
}

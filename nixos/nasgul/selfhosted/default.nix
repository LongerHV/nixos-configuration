_:

{
  imports = [
    ./auth.nix
    ./dashboard.nix
    # ./jupyter.nix
    ./lldap.nix
    ./minio.nix
    ./monitoring.nix
    ./multimedia.nix
    ./nameserver.nix
    ./nextcloud.nix
    ./wireguard.nix

    ./debt.nix
  ];
}

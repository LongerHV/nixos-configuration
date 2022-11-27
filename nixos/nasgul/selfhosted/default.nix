_:

{
  imports = [
    ./auth.nix
    ./dashboard.nix
    ./lldap.nix
    ./minio.nix
    ./monitoring.nix
    ./nameserver.nix
    ./nextcloud.nix
    ./wireguard.nix

    ./debt.nix
  ];
}

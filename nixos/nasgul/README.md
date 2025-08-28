# NASgul

Personal NAS server

## Features

- Mirrored ZFS boot drives

- 4x4TB hard drive Raid-Z1 array

- Traefik reverse proxy (with SSL)

- Blocky local DNS server with adblocking

- LLDAP authentication server

- Authelia SSO (using LLDAP as backend)

- Monitoring using Prometheus and Grafana

- Backups to S3 object storage with Restic

- MariaDB

- Redis cache/session provider

- Nextcloud

- Gitea

- Jellyfin media server

- Sonarr/Radarr/Bazarr/Prowlarr media management

- Deluge BitTorrent client (routed through wireguard)

- SMTP + Sendmail (through SendGrid)

- NixOS cache

## Adding a wireguard client

### Generate keys for the client

```bash
nix shell nixpkgs#wireguard-tools --command wg genkey > privatekey
nix shell nixpkgs#wireguard-tools --command wg pubkey < privatekey > publickey
```

### Create client config file

`client.conf`

```conf
[Interface]
PrivateKey = <content of privatekey file>
Address = <client IP>
DNS = 10.123.1.243

[Peer]
PublicKey = <server publickey>
AllowedIPs = 0.0.0.0/0
Endpoint = <server IP>:51820
```

### Generate QR code

This code can be scanned with the mobile wireguard app.

```bash
nix shell nixpkgs#qrencode --command qrencode -o wg.png < client.conf
xdg-open wg.png
```

### Add client to the server configuration

```nix
{
  networking.wireguard.interfaces.wg0.peers = [
    {
      publicKey = "<content of publickey file>";
      allowedIPs = [ "<client IP>" ];
    }
  ];
}
```

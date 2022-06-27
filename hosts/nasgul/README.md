# NASgul

Personal NAS server.

## Features

- Mirrored ZFS boot drives

- 4x4TB hard drive Raid-Z1 array

- Traefik reverse proxy (with SSL)

- Authelia SSO (in progress)

- Nextcloud

- Jellyfin media server

- Sonarr/Radarr/Bazarr/Prowlarr media management

- Transmission BitTorrent client

- Netdata monitoring

- NixOS cache

## TODO

[ ] Route transmission through wireguard (container?)

[ ] Configure Nextcloud SSO (with Authelia OIDC)

[ ] Integrate Authelia and Traefik (single factor for local services)

[ ] Redis (for authelia and nextcloud)

[ ] SMTP for Authelia

[ ] Use MariaDB for Authelia
([waiting for socket support](https://github.com/authelia/authelia/pull/3531))

[ ] Prometheus + Grafana

## Resources

- [Authelia tutorial](https://www.smarthomebeginner.com/docker-authelia-tutorial/)
- [Declarative containers](https://blog.beardhatcode.be/2020/12/Declarative-Nixos-Containers.html)

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

[ ] Integrate Authelia and Traefik

[x] Database (mariadb) - for authelia, gitea, nextcloud

[ ] Do I need LDAP ??? (maybe Authelia file storage is sufficient?)

[ ] Redis (for authelia)

[x] Add Cloudflare certificate (+ setup SSL on Traefik)

[x] Nextcloud

[x] Gitea

[ ] SMTP for Authelia

[ ] Prometheus + Grafana

## Resources

- [Authelia tutorial](https://www.smarthomebeginner.com/docker-authelia-tutorial/)
- [Declarative containers](https://blog.beardhatcode.be/2020/12/Declarative-Nixos-Containers.html)

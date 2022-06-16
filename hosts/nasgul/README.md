# NASgul

Personal NAS server.

## Features

- Mirrored ZFS boot drives

- 4x4TB hard drive Raid-Z1 array

- Traefik reverse proxy

- Authelia SSO (in progress)

- Jellyfin media server

- Sonarr/Radarr/Bazarr/Prowlarr media management

- Transmission BitTorrent client

- Netdata monitoring

- NixOS cache

## TODO

[ ] Integrate Authelia and Traefik

[ ] Database (maria, postgresql?) - for authelia, gitea, nextcloud

[ ] Do I need LDAP ??? (maybe Authelia file storage is sufficient?)

[ ] Redis (for authelia)

[ ] Add Cloudflare certificate (+ setup SSL on Traefik)

[ ] Nextcloud

[ ] Gitea

[ ] Prometheus + Grafana

## Resources

- [Authelia tutorial](https://www.smarthomebeginner.com/docker-authelia-tutorial/)

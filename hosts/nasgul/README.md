# NASgul

Personal NAS server.

## Features

- Mirrored ZFS boot drives

- 4x4TB hard drive Raid-Z1 array

- Traefik reverse proxy (with SSL)

- Authelia SSO

- Dashy dashboard

- Redis cache/session provider

- Nextcloud

- Jellyfin media server

- Sonarr/Radarr/Bazarr/Prowlarr media management

- Deluge BitTorrent client (routed through wireguard)

- Netdata monitoring

- NixOS cache

## TODO

- [ ] Move Deluge and *Arr to a container and route traffic via wireguard

- [ ] Extract dashboard entries to proper modules

- [ ] LDAP? (LDAP as Authelia backend, Jellyfin, Gitea, NextCloud)

- [ ] Nextcloud - SSO (with Authelia OIDC or LDAP)

- [ ] Nextcloud - redis cache

- [ ] Authelia - SMTP

- [ ] Use MariaDB for Authelia
([waiting for socket support](https://github.com/authelia/authelia/pull/3531))

- [ ] MinIO (for backups and Loki)

- [ ] Prometheus + Grafana + Loki

## Resources

- [Authelia tutorial](https://www.smarthomebeginner.com/docker-authelia-tutorial/)
- [Declarative containers](https://blog.beardhatcode.be/2020/12/Declarative-Nixos-Containers.html)

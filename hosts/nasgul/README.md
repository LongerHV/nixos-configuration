# NASgul

Personal NAS server.

## Features

- Mirrored ZFS boot drives

- 4x4TB hard drive Raid-Z1 array

- Traefik reverse proxy (with SSL)

- Authelia SSO

- Dashy dashboard

- Nextcloud

- Jellyfin media server

- Sonarr/Radarr/Bazarr/Prowlarr media management

- Deluge BitTorrent client (routed through wireguard)

- Netdata monitoring

- NixOS cache

## TODO

- [ ] Extract dashboard entries to proper modules

- [ ] Configure Nextcloud SSO (with Authelia OIDC)

- [ ] Redis (for authelia and nextcloud)

- [ ] SMTP for Authelia

- [ ] Use MariaDB for Authelia
([waiting for socket support](https://github.com/authelia/authelia/pull/3531))

- [ ] Prometheus + Grafana

## Resources

- [Authelia tutorial](https://www.smarthomebeginner.com/docker-authelia-tutorial/)
- [Declarative containers](https://blog.beardhatcode.be/2020/12/Declarative-Nixos-Containers.html)

# NASgul

Personal NAS server.

## Features

- Mirrored ZFS boot drives

- 4x4TB hard drive Raid-Z1 array

- Traefik reverse proxy (with SSL)

- LLDAP authentication server

- Authelia SSO (using LLDAP)

- Dashy dashboard

- MariaDB

- Redis cache/session provider

- MinIO object storage

- Nextcloud

- Jellyfin media server

- Sonarr/Radarr/Bazarr/Prowlarr media management

- Deluge BitTorrent client (routed through wireguard)

- Netdata monitoring

- SMTP + Sendmail (through SendGrid)

- NixOS cache

## TODO

- [ ] Move Deluge and *Arr to a container and route traffic via wireguard

- [ ] Extract dashboard entries to proper modules

- [x] LDAP (LDAP as Authelia backend)

- [ ] LLDAP - SMTP

- [ ] Authelia - Add groups and rules for services

- [ ] Nextcloud - SSO (with Authelia OIDC or LDAP)

- [ ] Nextcloud - redis cache

- [x] Nextcloud - SMTP

- [x] Authelia - SMTP (mailhog for now)

- [x] Use MariaDB for Authelia

- [ ] Use mysql socket for Authelia.
([waiting for socket support](https://github.com/authelia/authelia/pull/3531))

- [x] MinIO (for backups and Loki)

- [ ] Prometheus + Grafana + Loki

- [ ] Invoicing service (InvoicePlane, InvoiceNinja)

## Resources

- [Authelia tutorial](https://www.smarthomebeginner.com/docker-authelia-tutorial/)
- [Declarative containers](https://blog.beardhatcode.be/2020/12/Declarative-Nixos-Containers.html)
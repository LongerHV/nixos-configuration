# NASgul

Personal NAS server

## Features

- Mirrored ZFS boot drives

- 4x4TB hard drive Raid-Z1 array

- Traefik reverse proxy (with SSL)

- LLDAP authentication server

- Authelia SSO (using LLDAP as backend)

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

- [ ] Backups (Scaleway S3 + restic?)
- [ ] Move Deluge and \*Arr to a container and route traffic via wireguard
- [ ] LLDAP - SMTP
- [ ] Nextcloud - SSO (with Authelia OIDC)
- [ ] Nextcloud - redis cache
- [ ] Prometheus + Grafana + Loki
- [ ] Invoicing service (InvoicePlane, InvoiceNinja)

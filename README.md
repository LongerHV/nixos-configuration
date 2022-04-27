# My NixOS configuration

## Installation (assuming host config already exists)

```bash
# All as root
HOST=...  # set host variable to use proper configuration

nix-shell -p git nixFlakes
git clone https://this.repo.url/ /etc/nixos
nixos-install --root /mnt --impure --flake .#$HOST

# Reboot
```

## Update

```bash
nixos-rebuild switch --flake .
```

## Resources

* [hlissner dotfiles](https://github.com/hlissner/dotfiles)
* [adfaure nix configuration](https://github.com/adfaure/nix_configuration)
* [Home-manager docs](https://nix-community.github.io/home-manager/index.html#ch-nix-flakes)

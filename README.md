# My NixOS configuration

## NixOS

### Installation (assuming host config already exists)

```bash
# All as root
HOST=...  # set host variable to use proper configuration

nix-shell
git clone https://this.repo.url/ /etc/nixos
cd /etc/nixos
nixos-install --root /mnt --impure --flake .#$HOST

# Reboot
```

### System update

```bash
# Go to the repo directory
nixos-rebuild switch --flake .
```

## Non-NixOS

Example steps necessary to bootstrap and use this configuration on Ubuntu.

### Installation

First make sure, your user is in the sudo/wheel group.

```bash
# Install git, curl and xz (e.g. for ubuntu)
sudo apt install git xz-utils curl

# Clone this repository
git clone https://gitlab.com/LongerHV/nixos-configuration.git
cd nixos-configuration

# Install nix (single-user installation)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Activate nix profile (and add it to the .profile)
. ~/.nix-profile/etc/profile.d/nix.sh
echo ". $HOME/.nix-profile/etc/profile.d/nix.sh" >> ~/.profile
echo ". $HOME/.nix-profile/etc/profile.d/nix.sh" >> ~/.zprofile

# Open tempoary shell with nix and home-manager
nix-shell

# Remove nix (this is necessary, so home-manager can install nix)
nix-env -e nix

# Install the configuration (replace `<configname>` with actual configuration name from `flake.nix`)
home-manager switch --flake .#<configname>

# Exit temporary shell
exit

# Set zsh (installed by nix) as default shell
echo ~/.nix-profile/bin/zsh | sudo tee -a /etc/shells
usermod -s ~/.nix-profile/bin/zsh $USER
```

### Update

```bash
# Go to the repo directory
home-manager switch --flake .
```

## Live ISO

```bash
nix build .#nixosConfigurations.isoimage.config.system.build.isoImage
```

## TODO

- [ ] Add [refactoring](https://github.com/ThePrimeagen/refactoring.nvim) with [Null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#refactoring) integration

- [ ] Figure out what is wrong with nix managed typescript-language-server in nvim

- [ ] Consider [Alejandra](https://github.com/kamadorueda/alejandra) for formatting nix

## Resources

- [Nix config template](https://github.com/Misterio77/nix-starter-configs)
- [hlissner dotfiles](https://github.com/hlissner/dotfiles)
- [adfaure nix configuration](https://github.com/adfaure/nix_configuration)
- [Home-manager docs](https://nix-community.github.io/home-manager/index.html#ch-nix-flakes)
- [Building NixOS ISO](https://ash64.eu/2022/03/08/custom-nixos-isos/)
- [NixOS manual](https://nixos.org/manual/nix/stable)

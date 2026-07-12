# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS flake-based configuration repository managing multiple hosts and home-manager configurations. The repository uses a modular architecture with custom modules split between NixOS system configuration and home-manager user configuration.

## Host Configurations

The repository manages multiple hosts located in `nixos/`:
- **mordor**: Main workstation with Intel CPU, AMD GPU, ZFS storage, LUKS encryption with FIDO2/Yubikey support, gaming, audio production, and development features
- **nasgul**: Server/homelab host with AMD CPU/GPU, ZFS storage, running self-hosted services via the `homelab` module
- **smaug**: Raspberry Pi running alongside Klipper powered 3d printer
- **playground**: Test/experimental configuration
- **isoimage** / **isoimage-server**: Live ISO configurations
- **sd-image**: SD card image for ARM devices

## Build and Development Commands

### System Management (NixOS)
```bash
# Build and switch system configuration (on NixOS host)
nixos-rebuild switch --flake .

# Build specific host configuration without switching
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Deploy to remote host (nasgul or smaug)
nix run github:serokell/deploy-rs -- .#<hostname>
```

### Home Manager (non-NixOS systems)
```bash
# Switch home-manager configuration
home-manager switch --flake .#mmieszczak
```

### Build ISO Images
```bash
# Build graphical installer ISO
nix build .#nixosConfigurations.isoimage.config.system.build.isoImage

# Build minimal server ISO
nix build .#nixosConfigurations.isoimage-server.config.system.build.isoImage

# Build SD card image
nix build .#nixosConfigurations.sd-image.config.system.build.sdImage
```

### Development Shells
Multiple development shells are available via `nix develop`:
```bash
nix develop              # Default shell (nix, home-manager, git)
nix develop .#node       # Node.js development
nix develop .#go         # Go development
nix develop .#python     # Python development
nix develop .#pythonPoetry  # Python with Poetry
nix develop .#pythonUV   # Python with uv
nix develop .#pythonVenv # Python with venv
nix develop .#lint       # Linting tools
```

### Linting and Checks
```bash
# Enter lint shell and run linters
nix develop .#lint

# Run flake checks (evaluates all configurations)
nix flake check --no-build --all-systems

# Format Nix files
nixpkgs-fmt .

# Check Nix files for issues
statix check

# Lint YAML files
yamllint .

# Lint Lua files
selene .
stylua --check .
```

## Architecture

### Flake Structure
- **inputs**: Uses nixpkgs 25.11, home-manager, agenix (secrets), deploy-rs, and custom overlays
- **overlays**: Custom packages in `overlay/` (e.g., templ, xerox), plus external overlays for neovim-plugins, kubectl, nixgl
- **outputs**: Exposes nixosConfigurations, homeConfigurations, devShells, templates, and deployment configurations

### Module System

**NixOS Modules** (`modules/nixos/`):
- `mySystem`: Core system configuration module with submodules:
  - `android.nix`: Android development tools
  - `embedded.nix`: Embedded development tools
  - `gaming.nix`: Gaming support (Steam, Lutris, etc.)
  - `gnome.nix`: GNOME desktop environment
  - `rtaudio.nix`: Real-time audio configuration
  - `user.nix`: User account management
  - `virt.nix`: Virtualization support
- `homelab`: Self-hosted services module with submodules for Traefik, Nextcloud, Gitea, monitoring, multimedia, backups, mail, databases
- `sunshine`: Sunshine game streaming

**Home Manager Modules** (`modules/home-manager/`):
- `default`: Base home-manager configuration with XDG directories
- `myHome`: User environment modules:
  - `cli.nix`: CLI tools and utilities
  - `colors.nix`: Color scheme configuration
  - `devops.nix`: DevOps tools (kubectl, helm, terraform, etc.)
  - `gnome/`: GNOME desktop customization
  - `music-production.nix`: Audio production tools
  - `neovim/`: Neovim configuration
  - `non-nixos.nix`: Non-NixOS specific configuration
  - `tmux.nix`: Tmux configuration
  - `zsh/`: ZSH shell configuration

### Secrets Management
- Uses `agenix` for encrypted secrets stored in `secrets/`
- Secrets are encrypted with age and referenced in host configurations
- Each host has its own set of encrypted secrets (e.g., `nasgul_*`, `mordor_*`)

### Homelab Services
The `homelab` module (used on nasgul) provides:
- **Reverse proxy**: Traefik with automatic HTTPS
- **Cloud storage**: Nextcloud
- **Git hosting**: Gitea with actions runner
- **Monitoring**: Prometheus, Grafana
- **Media**: Jellyfin, *arr stack
- **Backups**: Restic
- **Mail**: Postfix relay
- **Databases**: MySQL, Redis
- **DNS**: Blocky ad-blocking DNS server

Configuration uses `homelab.domain` and `homelab.storage` options to set domain and storage paths.

### Binary Cache
- nasgul and mordor hosts run `nix-serve` to provide binary caches
- Configurations reference these caches via `mySystem.nix.substituters` option
- mordor uses nasgul's cache, nasgul uses mordor's cache

## Key Patterns

### Adding a New Host
1. Create directory in `nixos/<hostname>/`
2. Create `default.nix` importing hardware-configuration and desired modules
3. Set `mySystem` options to enable features
4. Add to `nixosConfigurations` in `flake.nix`
5. Optionally add to `deploy.nodes` for remote deployment

### Enabling Features on a Host
Use `mySystem` options in host's `default.nix`:
```nix
mySystem = {
  gnome.enable = true;      # Enable GNOME desktop
  gaming.enable = true;      # Enable gaming support
  embedded.enable = true;    # Enable embedded dev tools
  vmHost = true;             # Enable virtualization host
  dockerHost = true;         # Enable Docker
  rtaudio.enable = true;     # Enable real-time audio
  home-manager = {
    enable = true;
    home = ./home.nix;       # Path to home-manager config
  };
  nix.substituters = [ "nasgul" ];  # Use binary cache
};
```

### Home Manager Integration
Home-manager is integrated as a NixOS module (not standalone). Each host specifies its home configuration via `mySystem.home-manager.home` option.

## Locale and Regional Settings
- Default timezone: `Europe/Warsaw`
- Default locale: `pl_PL.UTF-8`
- Console keymap: `pl` (Polish)
- XDG directories use Polish names (Dokumenty, Pobrane, etc.)

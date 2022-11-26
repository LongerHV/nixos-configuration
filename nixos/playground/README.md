# Playground NixOS container

Spin up a TTY only container using systemd nspawn to experiment with configuration.

```bash
# Create container from configuration flake
sudo nixos-container create playground \
    --local-address 10.235.1.2 \
    --host-address 10.235.1.1 \
    --flake .#playground

# Update container
sudo nixos-container update playground --flake .#playground

# Start container
sudo nixos-container start playground

# Attach to container TTY
sudo nixos-container login playground

# Stop when done testing
sudo nixos-container stop playground

# Destroy container
sudo nixos-container destroy playground
```

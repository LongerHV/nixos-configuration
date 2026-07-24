# Ender3 3d printer running klipper

```bash
# Build firmware with
nix build .\#nixosConfigurations.smaug.config.services.klipper.firmwares.mcu.package

# Copy result/klipper.bin to microSD card (make sure to use new unique name),
# plug it to the printer and power cycle.
```

## Thanks

- [Awesome article by Van Tuan Vo](https://medium.com/@vtuan10/using-nixos-for-3d-printing-4f5ba1c11db2)

# Ender3 3d printer running klipper

Mainboard: Creality V4.2.2 (STM32F103RET6). The stock Creality bootloader was
replaced with [Katapult](https://github.com/Arksine/katapult) (serial, USART1
PA10/PA9, 250000 baud, 8KiB), so klipper is built with an 8KiB bootloader offset
(`CONFIG_FLASH_APPLICATION_ADDRESS=0x8002000`) and flashed over USB - no SD card.

```bash
# Build firmware with
nix build .\#nixosConfigurations.smaug.config.services.klipper.firmwares.mcu.package

# Flash it over USB on smaug. After deploying, this flashes the firmware
# built from ./config (or a path given as argument) and restarts klipper:
klipper-flash-mcu

# Manual equivalent (katapult-flashtool, see overlay/katapult-flashtool.nix)
DEV=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0
sudo systemctl stop klipper
katapult-flashtool -d $DEV -b 250000 -r                    # ask klipper to jump to katapult
katapult-flashtool -d $DEV -b 250000 -f result/klipper.bin
sudo systemctl start klipper
```

## Recovery (ST-Link)

The firmware reconfigures the SWD pins at boot, so SWD only works with the core
held from the reset vector: hold RST low, set the vector catch
(`mww 0xE000EDFC 0x01000001` in openocd), release RST - the core halts before
any code runs. Then `stm32f1x mass_erase 0` and
`flash write_image katapult.bin 0x08000000 bin`. If no valid klipper image is
present, katapult stays in bootloader mode and accepts `flashtool.py -f`.

## Thanks

- [Awesome article by Van Tuan Vo](https://medium.com/@vtuan10/using-nixos-for-3d-printing-4f5ba1c11db2)

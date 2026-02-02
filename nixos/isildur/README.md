# Isildur

Raspberry Pi Zero 2 W running OpenThread Border router.

## Notes

It may be necessary to manuall turn off wifi powersave,
otherwise routes from other machines may not be stable.

```
sudo nmcli connection modify "<SSID>" 802-11-wireless.powersave 2
```

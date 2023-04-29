# Mordor

My dailydriver

## Running a test VM

```bash
nixos-rebuild build-vm --flake .#mordor
result/bin/run-mordor-vm

# Remove disk image after you are done
rm mordor.qcow2
```

## TODO

- [ ] Periodic ZFS send to NASgul (sanoid + syncoid?)
- [ ] Try using gnome-terminal with Ubuntu patches [git](https://salsa.debian.org/gnome-team/gnome-terminal/-/tree/ubuntu/3.46.7-1ubuntu1)

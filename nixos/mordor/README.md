# Mordor

My dailydriver

## Running a test VM

```bash
nixos-rebuild build-vm --flake .#mordor
result/bin/run-mordor-vm

# Remove disk image after you are done
rm mordor.qcow2
```

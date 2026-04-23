# Nebula

Overlay network for secure communication between machines.

## Generating certs

```bash
# Make sure appropriate entries exist in secrets.nix

# CA
nix shell self#nebula --command nebula-cert ca -name Longer -duration 43800h
cat ca.key | agenix -e ca.key.age
git add ca.cert ca.key.age

# Host (e.g. Nasgul)
nix shell self#nebula --command nebula-cert sign -name nasgul -ip "10.42.0.1/24" -groups "lighthouse,prometheus"
cat nasgul.key | agenix -e nasgul.key.age
git add nasgul.cert nasgul.key.age

# Cleanup (make sure keys are not commited)
rm nasgul.key
rm ca.key
```

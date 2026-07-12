# Palantir plasma-bigscreen: migrate to nixpkgs-unstable's package

## Problem

`palantir` (the plasma-bigscreen HTPC host) stopped building after upgrading to
`nixos-26.05`. Root cause: `mkKdeDerivation` in `nixos-26.05` gained a new
`qmlLintCheck` install-check hook (`pkgs/kde/lib/qmllint-hook.sh`) that fails
the build on any QML file with a "Failed to import" warning. The repo's
custom `overlay/plasma-bigscreen.nix` derivation (built from an old
`plasma-bigscreen` git snapshot, version 6.4.80) trips this check on
`WebAppView.qml`'s self-import of `org.kde.bigscreen.webapp`.

Separately, `nixpkgs-unstable` now ships `kdePackages.plasma-bigscreen`
(6.7.2) as a first-class package (part of the Plasma 6.7 release), which the
pinned `nixos-26.05` input does not have. Upstream's own package definition
already sets `dontQmlLint = true` and needs neither the QML private-API patch
nor the `noDisplay()` C++ fix nor the manual session-script rewriting that
the custom overlay derivation carries — that hand-maintained workaround
surface can be deleted entirely.

## Decision

Replace the custom-built overlay derivation with nixpkgs-unstable's official
`kdePackages.plasma-bigscreen`, sourced via the repo's existing
`pkgs.unstable` overlay pattern (already used elsewhere, e.g.
`inherit (prev.unstable) klipper-firmware;` in `overlay/default.nix`).

**Version consistency requirement:** `nixpkgs-unstable`'s `plasma-bigscreen`
is built against Frameworks/Plasma 6.7.2 / KF 6.28.0. The pinned
`nixos-26.05` ships `plasma-workspace`/`kwin`/`libplasma` at 6.6.6 / KF
6.26.0. Running a 6.7.2 `plasma-bigscreen` against a 6.6.6 `plasma-workspace`
+ `kwin` risks the same class of QML/ABI incompatibility that
`plasma-bigscreen-qmlprivate.patch` was originally written to paper over. So
every KDE package that `plasma-bigscreen` talks to directly (QML imports,
D-Bus, kactivitymanagerd, the portal) moves to `pkgs.unstable.kdePackages`
together, not just `plasma-bigscreen` itself. SDDM, Xwayland, and pipewire
are not Frameworks-version-coupled and stay on the pinned `nixos-26.05`.

`modules/nixos/plasma-bigscreen.nix` (the custom NixOS module: SDDM
session/autologin wiring, `environment.systemPackages`, portal config,
and the HTPC-specific systemd workarounds) remains necessary — confirmed via
grep that nixpkgs ships zero NixOS module integration for
`plasma-bigscreen` (unlike full Plasma 6, which gets
`services.desktopManager.plasma6`). Only the package *sourcing* changes.

## Scope

### 1. `overlay/default.nix`
Replace:
```nix
plasma-bigscreen = prev.kdePackages.callPackage ./plasma-bigscreen.nix { };
```
with:
```nix
inherit (prev.unstable.kdePackages) plasma-bigscreen;
```

### 2. Delete
- `overlay/plasma-bigscreen.nix`
- `overlay/plasma-bigscreen-qmlprivate.patch`

### 3. `modules/nixos/plasma-bigscreen.nix`
Move every KDE package referenced that is version-coupled to
`plasma-workspace`/`kwin` from `pkgs.kdePackages` to
`pkgs.unstable.kdePackages`:
- `environment.systemPackages`: `plasma-workspace`, `plasma-nano`,
  `plasma-nm`, `plasma-pa`, `milou`, `kscreen`, `kdeconnect-kde`, `kwin`,
  `breeze`, `qqc2-breeze-style`, `kactivitymanagerd`, `kglobalacceld`,
  `kded`, `kde-cli-tools`
- `xdg.portal.extraPortals`: `xdg-desktop-portal-kde`

`pkgs.plasma-bigscreen` references need no code change (the overlay change
makes that symbol resolve to the unstable package automatically).

**Left untouched, deliberately** (cannot verify these without deploying to
real hardware, so no speculative removal):
- SDDM, Xwayland, pipewire configuration
- `programs.kdeconnect.enable`
- All existing runtime workarounds: `plasma-kcminit`/`plasma-ksmserver`
  no-ops, `kactivitymanagerd` systemd ordering, the `XDG_DATA_DIRS`/`PATH`
  `serviceConfig.Environment` overrides on `plasma-plasmashell`, the
  `QT_QPA_PLATFORMTHEME` kwin-crash workaround and its portal-side restore.

One comment block cites a specific version combo ("Qt 6.10.1 + KWin 6.5.5")
for the kwin crash workaround; that comment gets a note flagging it as
possibly stale now that kwin is 6.7.2, without removing the workaround
itself.

### 4. `nixos/palantir/home.nix`
No changes — nothing there references package versions directly.

## Out of scope
- Removing any of the systemd/environment workarounds in the module. They
  were discovered empirically at runtime; only the user, testing on the
  actual `palantir` hardware, can confirm which (if any) are no longer
  needed at 6.7.2.
- Bumping `palantir`'s entire `nixpkgs` input to unstable. Only the
  Plasma/KDE Frameworks package set used by this one module moves.

## Verification plan
1. `nix build .#nixosConfigurations.palantir.config.system.build.toplevel`
   must succeed (this is the regression the whole change fixes).
2. `nix flake check --no-build --all-systems` should still pass.
3. User deploys to the physical `palantir` host and verifies the
   `plasma-bigscreen-wayland` session actually boots and is usable —
   the specific things worth re-checking, called out for the user:
   - Does the kwin-crash workaround (`QT_QPA_PLATFORMTHEME=generic` for
     kwin, restored to `kde` for plasmashell/portal) still apply at kwin
     6.7.2, or can it be dropped?
   - Do `plasma-kcminit`/`plasma-ksmserver` still hang for ~90s, or has
     upstream fixed that in 6.7.2?
   - App-discovery / `XDG_DATA_DIRS` and `PATH` overrides on
     `plasma-plasmashell.service` — still required?
4. Update the `project_palantir_bigscreen` memory afterward with the new
   package provenance and whatever the user finds during runtime testing.

# Palantir plasma-bigscreen: migrate to nixpkgs-unstable Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix palantir's broken NixOS build (nixos-26.05's `mkKdeDerivation` gained a `qmlLintCheck` hook that fails on the custom `plasma-bigscreen` overlay derivation) by replacing the custom-built derivation with nixpkgs-unstable's official `kdePackages.plasma-bigscreen` (6.7.2), and version-matching the rest of the Plasma stack the module depends on so it doesn't reintroduce the QML/ABI mismatch class of bug the old custom patch worked around.

**Architecture:** This is a NixOS flake configuration repo, not an application — there is no test framework; "tests" are `nix build`/`nix flake check` invocations. Three tasks: (1) swap the overlay's `plasma-bigscreen` package source and delete the now-dead custom derivation files, (2) move the module's version-coupled KDE package references to `pkgs.unstable.kdePackages` and flag one now-stale comment, (3) full-repo verification plus updating the project memory file with findings for the user's runtime testing pass.

**Tech Stack:** Nix flakes, NixOS modules, nixpkgs overlays (`nixpkgs` pinned to `nixos-26.05`, `nixpkgs-unstable` available as `pkgs.unstable` via existing overlay).

## Global Constraints

- palantir's system `nixpkgs` input stays pinned to `nixos-26.05`; only the specific KDE/Plasma packages this module touches move to `pkgs.unstable.kdePackages`. Do not bump the whole flake input.
- SDDM, Xwayland, and pipewire configuration stay on the pinned `nixos-26.05` nixpkgs (not Frameworks-version-coupled).
- Do not remove or "fix" any existing systemd/environment workaround in `modules/nixos/plasma-bigscreen.nix` (kcminit/ksmserver no-ops, kactivitymanagerd ordering, `XDG_DATA_DIRS`/`PATH` overrides, kwin crash QT_QPA_PLATFORMTHEME dance) — only flag comments that reference now-superseded behavior. These can only be safely removed after the user verifies on real hardware.
- `nixos/palantir/home.nix` is out of scope — no changes.
- Session name must remain `"plasma-bigscreen-wayland"` (confirmed to match between the old custom derivation's `passthru.providedSessions` and nixpkgs-unstable's).

---

### Task 1: Swap plasma-bigscreen package source to nixpkgs-unstable

**Files:**
- Modify: `overlay/default.nix:2`
- Delete: `overlay/plasma-bigscreen.nix`
- Delete: `overlay/plasma-bigscreen-qmlprivate.patch`

**Interfaces:**
- Produces: `pkgs.plasma-bigscreen` now resolves to `nixpkgs-unstable`'s `kdePackages.plasma-bigscreen` (version 6.7.2) instead of the custom-built 6.4.80 derivation. Every other file in the repo that references `pkgs.plasma-bigscreen` (there is exactly one: `modules/nixos/plasma-bigscreen.nix`) needs no code change because of this — Task 2 relies on this.

- [ ] **Step 1: Confirm the current build fails with the qmllint error (baseline)**

Run: `nix build .#nixosConfigurations.palantir.config.system.build.toplevel --no-link 2>&1 | tail -20`
Expected: FAIL, ending in `error: Cannot build '/nix/store/...-plasma-bigscreen-6.4.80.drv'` with `qmllint failed for file ... WebAppView.qml` somewhere in the log. (This should already be the state of the repo — this step is just confirming nothing has drifted before you start.)

- [ ] **Step 2: Edit `overlay/default.nix`**

Change line 2 from:
```nix
  plasma-bigscreen = prev.kdePackages.callPackage ./plasma-bigscreen.nix { };
```
to:
```nix
  inherit (prev.unstable.kdePackages) plasma-bigscreen;
```

This matches the existing `inherit (prev.unstable) klipper-firmware;` pattern already used lower in the same file.

- [ ] **Step 3: Delete the now-dead custom derivation files**

```bash
git rm overlay/plasma-bigscreen.nix overlay/plasma-bigscreen-qmlprivate.patch
```

- [ ] **Step 4: Stage the overlay change and build the package in isolation**

```bash
git add overlay/default.nix
nix build --impure --expr 'let f = builtins.getFlake (toString ./.); in f.nixosConfigurations.palantir.pkgs.plasma-bigscreen' --no-link -L 2>&1 | tail -30
```
Expected: SUCCESS (build completes, no `qmlLintCheck` failure, no references to the deleted `overlay/plasma-bigscreen.nix`/patch file). The `-L` flag prints full build logs so you can confirm `qmlLintCheck` either doesn't run or passes (upstream sets `dontQmlLint = true`, so it should be skipped entirely — you should NOT see a "Running qmlLintCheck" line at all).

- [ ] **Step 5: Build the full palantir system to confirm the original regression is fixed**

```bash
nix build .#nixosConfigurations.palantir.config.system.build.toplevel --no-link 2>&1 | tail -30
```
Expected: SUCCESS. This is the exact command that failed in Step 1 — it must now complete without error. This mixes unstable's `plasma-bigscreen` with the pinned `nixos-26.05` `plasma-workspace`/`kwin` (Task 2 hasn't run yet), so it builds fine (nixpkgs doesn't statically check cross-version ABI compatibility) but is not yet version-consistent — that's what Task 2 fixes.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
[Overlay] Source plasma-bigscreen from nixpkgs-unstable

nixos-26.05's mkKdeDerivation gained a qmlLintCheck install-check hook
that fails the custom plasma-bigscreen-6.4.80 overlay derivation on a
WebAppView.qml self-import warning. nixpkgs-unstable now ships
kdePackages.plasma-bigscreen (6.7.2) as an official package that needs
none of the custom patches, so use that instead of maintaining a
hand-built derivation.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Version-match the Plasma stack in the NixOS module

**Files:**
- Modify: `modules/nixos/plasma-bigscreen.nix:40-55` (environment.systemPackages)
- Modify: `modules/nixos/plasma-bigscreen.nix:57-61` (xdg.portal.extraPortals)
- Modify: `modules/nixos/plasma-bigscreen.nix:122-131` (stale comment on the portal QT_QPA_PLATFORMTHEME workaround)

**Interfaces:**
- Consumes: `pkgs.plasma-bigscreen` from Task 1 (already resolves to unstable, unchanged in this task).
- Produces: `environment.systemPackages` and `xdg.portal.extraPortals` now source their KDE packages from `pkgs.unstable.kdePackages` instead of `pkgs.kdePackages`, keeping every Plasma-stack package the module touches at the same 6.7.2/Frameworks-6.28 version as `plasma-bigscreen` itself.

- [ ] **Step 1: Edit `environment.systemPackages` in `modules/nixos/plasma-bigscreen.nix`**

Replace:
```nix
    environment.systemPackages = with pkgs.kdePackages; [
      plasma-workspace
      plasma-nano
      plasma-nm
      plasma-pa
      milou
      kscreen
      kdeconnect-kde
      kwin
      breeze
      qqc2-breeze-style
      kactivitymanagerd
      kglobalacceld
      kded
      kde-cli-tools
    ];
```
with:
```nix
    # Sourced from pkgs.unstable to stay version-matched with plasma-bigscreen,
    # which nixpkgs-unstable ships ahead of the pinned nixos-26.05 nixpkgs
    # (Plasma 6.7.2 / Frameworks 6.28 vs 6.6.6 / 6.26 as of 2026-07-12). Mixing
    # Plasma minor versions here risks the same QML/ABI breakage the deleted
    # plasma-bigscreen-qmlprivate.patch used to work around.
    environment.systemPackages = with pkgs.unstable.kdePackages; [
      plasma-workspace
      plasma-nano
      plasma-nm
      plasma-pa
      milou
      kscreen
      kdeconnect-kde
      kwin
      breeze
      qqc2-breeze-style
      kactivitymanagerd
      kglobalacceld
      kded
      kde-cli-tools
    ];
```

- [ ] **Step 2: Edit `xdg.portal` in `modules/nixos/plasma-bigscreen.nix`**

Replace:
```nix
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = "*";
    };
```
with:
```nix
    xdg.portal = {
      enable = true;
      # pkgs.unstable to stay version-matched with the rest of the Plasma
      # stack above (see environment.systemPackages comment).
      extraPortals = [ pkgs.unstable.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = "*";
    };
```

- [ ] **Step 3: Update the stale QT_QPA_PLATFORMTHEME comment**

The old custom overlay derivation's `postInstall` script set `QT_QPA_PLATFORMTHEME=generic` for kwin and propagated it via `dbus-update-activation-environment`, which is what the `plasma-xdg-desktop-portal-kde` override below was compensating for. That script no longer exists (deleted in Task 1) — confirmed by inspecting nixpkgs-unstable's `plasma-bigscreen-wayland.in` source, which does not set `QT_QPA_PLATFORMTHEME` at all. Flag this instead of guessing whether the workaround is still needed.

Replace:
```nix
        # Restore QT_QPA_PLATFORMTHEME=kde for the portal process.
        # plasma-bigscreen-wayland sets QT_QPA_PLATFORMTHEME=generic AFTER calling
        # dbus-update-activation-environment, but the startplasma-wayland C wrapper
        # calls it again internally — propagating 'generic' to all user services.
        # The portal uses QApplication::palette() (not KColorScheme) to report
        # dark-mode preference, so it needs the KDE platform theme to read kdeglobals.
        # The kwin crash (null QKdeTheme during cold init) is specific to kwin.
        plasma-xdg-desktop-portal-kde = {
          overrideStrategy = "asDropin";
          serviceConfig.Environment = [ "QT_QPA_PLATFORMTHEME=kde" ];
        };
```
with:
```nix
        # Restore QT_QPA_PLATFORMTHEME=kde for the portal process.
        # STALE as of the 2026-07-12 migration to nixpkgs-unstable's plasma-bigscreen
        # package: this compensated for QT_QPA_PLATFORMTHEME=generic being set by the
        # old custom overlay derivation's postInstall script (deleted). Upstream's
        # plasma-bigscreen-wayland.in does not set QT_QPA_PLATFORMTHEME at all, so this
        # override — and the kwin-crash workaround it was protecting against, tuned
        # against Qt 6.10.1 + KWin 6.5.5 — may no longer be necessary. Verify at
        # runtime before removing.
        # The portal uses QApplication::palette() (not KColorScheme) to report
        # dark-mode preference, so it needs the KDE platform theme to read kdeglobals.
        plasma-xdg-desktop-portal-kde = {
          overrideStrategy = "asDropin";
          serviceConfig.Environment = [ "QT_QPA_PLATFORMTHEME=kde" ];
        };
```

- [ ] **Step 4: Rebuild the full palantir system**

```bash
git add modules/nixos/plasma-bigscreen.nix
nix build .#nixosConfigurations.palantir.config.system.build.toplevel --no-link 2>&1 | tail -30
```
Expected: SUCCESS. Same command as Task 1 Step 5 — must still succeed with the version-matched package set.

- [ ] **Step 5: Confirm the session name and package set evaluate as expected**

```bash
nix eval --impure --expr 'let f = builtins.getFlake (toString ./.); in f.nixosConfigurations.palantir.config.services.displayManager.defaultSession'
nix eval --impure --expr 'let f = builtins.getFlake (toString ./.); in f.nixosConfigurations.palantir.pkgs.unstable.kdePackages.plasma-workspace.version'
```
Expected: first command prints `"plasma-bigscreen-wayland"`; second prints `"6.7.2"`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "$(cat <<'EOF'
[Palantir] Version-match Plasma stack with unstable plasma-bigscreen

plasma-bigscreen now comes from nixpkgs-unstable (6.7.2 / Frameworks
6.28), so pull every KDE package this module directly interacts with
(plasma-workspace, kwin, libplasma-dependent packages, the portal) from
pkgs.unstable.kdePackages too, avoiding a repeat of the QML/ABI mismatch
class of bug the old plasma-bigscreen-qmlprivate.patch worked around.
Also flags a comment describing behavior tied to the now-deleted custom
derivation's postInstall script as stale, pending runtime verification.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Full-repo verification and memory update

**Files:**
- Modify: `/home/longer/.claude/projects/-home-longer-nixos-configuration/memory/project_palantir_bigscreen.md`

**Interfaces:**
- Consumes: nothing new — this is verification plus documentation of Tasks 1–2's outcome.

- [ ] **Step 1: Run the full flake check**

```bash
nix flake check --no-build --all-systems 2>&1 | tail -40
```
Expected: SUCCESS, no errors. This catches any other host/config that might reference `overlay/plasma-bigscreen.nix` or the old `pkgs.kdePackages.xdg-desktop-portal-kde`/`plasma-workspace` paths this change touched (there shouldn't be any outside `nixos/palantir` and the two modified files, but this is the safety net).

- [ ] **Step 2: Grep for any other references to the deleted files, to make sure nothing was missed**

```bash
grep -rn "plasma-bigscreen.nix\|plasma-bigscreen-qmlprivate" --include="*.nix" . 
```
Expected: no output (empty). If anything prints, it's a leftover reference that needs fixing before proceeding.

- [ ] **Step 3: Update the project memory file**

Read the current file first (`/home/longer/.claude/projects/-home-longer-nixos-configuration/memory/project_palantir_bigscreen.md`), then update it to reflect:
- `plasma-bigscreen` now sourced from `nixpkgs-unstable`'s `kdePackages.plasma-bigscreen` (6.7.2), not the custom-built overlay derivation (which is deleted, along with its patch file).
- `modules/nixos/plasma-bigscreen.nix`'s `environment.systemPackages` and `xdg.portal.extraPortals` now source from `pkgs.unstable.kdePackages` for version consistency.
- Add to "Known remaining issues" / open questions for the user's runtime test pass:
  - Whether the `QT_QPA_PLATFORMTHEME` kwin-crash workaround (kwin/portal serviceConfig.Environment overrides) is still needed at kwin 6.7.2 — the custom postInstall script that originally required the compensating portal override no longer exists.
  - Whether `plasma-kcminit`/`plasma-ksmserver` still hang ~90s at this version.
  - Whether the `XDG_DATA_DIRS`/`PATH` overrides on `plasma-plasmashell.service` are still required.
  - **New finding from this migration:** nixpkgs-unstable's `plasma-bigscreen-wayland.in` launcher invokes `startplasma-wayland --exit-with-session=${plasma-workspace}/libexec/startplasma-waylandsession`, but as of this writing `nixpkgs-unstable`'s `kdePackages.plasma-workspace` does **not** ship a `libexec/startplasma-waylandsession` file (verified by extracting both source tarballs and listing `plasma-workspace`'s build output — only `startplasma-wayland`/`startplasma-x11` exist in `bin/`, nothing named `startplasma-waylandsession` anywhere in the closure). This may be a nixpkgs packaging gap for 6.7.2 and could mean the session fails to exit cleanly, or `startplasma-wayland` may tolerate a missing `--exit-with-session` target gracefully — untested. If the session doesn't start or doesn't exit correctly, check this first.

- [ ] **Step 4: No commit needed for this step** — memory files live outside the git repo (`/home/longer/.claude/projects/...`), not in `nixos-configuration`. Nothing to stage or commit here.

- [ ] **Step 5: Final sanity check — status and log**

```bash
git status
git log --oneline -5
```
Expected: working tree clean (all changes from Tasks 1–2 committed), last two commits are the Task 1 and Task 2 commits.

## Self-Review

**Spec coverage:**
- Overlay swap → Task 1. ✓
- Delete dead files → Task 1 Step 3. ✓
- Version-match KDE package set → Task 2. ✓
- `modules/nixos/plasma-bigscreen.nix` confirmed still necessary, unchanged in structure → Task 2 only touches package sourcing + one comment, module structure untouched. ✓
- `home.nix` out of scope → no task touches it. ✓
- Stale comment flagging → Task 2 Step 3. ✓
- Verification plan (toplevel build, flake check, runtime punch-list) → Tasks 1, 2, 3. ✓
- Memory update → Task 3 Step 3. ✓

**Placeholder scan:** No TBD/TODO; every step has literal commands or literal diffs. Clean.

**Type/name consistency:** `pkgs.plasma-bigscreen`, `pkgs.unstable.kdePackages.*`, session name `"plasma-bigscreen-wayland"` used identically across Tasks 1–3.

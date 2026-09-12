{ inputs, config, lib, pkgs, ... }:

let
  # WayDroidATV ships a stock SurfaceFlinger: nothing under /system calls
  # vendor.waydroid.display@1.x::setLayerName, so waydroid's hwcomposer never
  # receives the "TID:<app>#<task>/<component>" layer names that its per-app
  # window modes match on. single_window_mode_base::should_show() is therefore
  # always false, and `waydroid app launch` ends up tearing down the window a
  # few seconds after start-up instead of showing the app. Full-UI mode does
  # not use those names, so launch the app and then present the whole Android
  # display, which on a TV image is the right presentation anyway.
  waydroid-tv-launch = pkgs.writeShellScriptBin "waydroid-tv-launch" ''
    pkg="''${1:-}"
    if [ -z "$pkg" ]; then
      echo "usage: waydroid-tv-launch <package>" >&2
      exit 1
    fi

    waydroid=${config.virtualisation.waydroid.package}/bin/waydroid

    # Also starts the session when none is running, blocking for its lifetime.
    "$waydroid" app launch "$pkg" &
    launcher=$!

    i=0
    while [ "$i" -lt 120 ]; do
      if [ "$("$waydroid" prop get waydroid.active_apps 2>/dev/null)" = "$pkg" ]; then
        break
      fi
      i=$((i + 1))
      sleep 1
    done
    sleep 2
    "$waydroid" show-full-ui

    wait "$launcher"
  '';
in

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  # This host is built against nixpkgs-unstable (see flake.nix), but
  # modules/nixos/mySystem/default.nix unconditionally maps every flake
  # input, including the pinned "nixpkgs", into nix.registry — conflicting
  # with nixpkgs-unstable's own nixos/modules/misc/nixpkgs-flake.nix, which
  # registers "nixpkgs" to point at itself. Force it to unstable here so
  # `nix run nixpkgs#...`/`nix shell nixpkgs#...` on this host resolve
  # against the same nixpkgs the system is actually built from.
  nix.registry.nixpkgs = lib.mkForce { flake = inputs.nixpkgs-unstable; };

  mySystem = {
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
    nix.substituters = [ "nasgul" ];
    plasma-bigscreen.enable = true;
  };
  homelab = {
    nebula.enable = true;
    monitoringTarget = {
      enable = true;
    };
  };

  nix.settings.trusted-users = [ config.mySystem.user ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true;
      luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
    zfs.forceImportRoot = false;
  };

  networking = {
    hostName = "palantir";
    hostId = "656ad412"; # required by ZFS
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    wl-clipboard
    android-tools
    waydroid-tv-launch
  ];

  programs = {
    steam = {
      enable = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /games 0755 ${config.mySystem.user} users -"
  ];

  services = {
    openssh.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 9999 ]; # libespot

  virtualisation = {
    waydroid = {
      enable = true;
      # Android TV apps only declare LEANBACK_LAUNCHER; upstream skips those when
      # syncing .desktop files, so they never reach the Bigscreen menu.
      package = pkgs.waydroid-nftables.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace tools/services/user_manager.py \
            --replace-fail \
              'if cat.strip() == "android.intent.category.LAUNCHER":' \
              'if cat.strip() in ("android.intent.category.LAUNCHER", "android.intent.category.LEANBACK_LAUNCHER"):'
          # Route the generated entries through waydroid-tv-launch (see above).
          substituteInPlace tools/services/user_manager.py \
            --replace-fail \
              'f"waydroid app launch {packageName}"' \
              'f"waydroid-tv-launch {packageName}"'
        '';
      });
    };
  };

  hardware = {
    bluetooth.enable = true;
    intelgpu.vaapiDriver = "intel-media-driver";
  };
  documentation.enable = false;
  system.stateVersion = "25.11";
}

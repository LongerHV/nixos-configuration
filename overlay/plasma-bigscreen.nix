{ lib
, mkKdeDerivation
, fetchurl
, pkg-config
, plasma-workspace
, qtsvg
, qtdeclarative
, qtwayland
, qtmultimedia
, qtwebengine
, bluez-qt
, ki18n
, kirigami
, kcmutils
, kglobalaccel
, knotifications
, kio
, kwindowsystem
, ksvg
, kdbusaddons
, kiconthemes
, libplasma
, plasma-activities
, plasma-activities-stats
, plasma-nano
, plasma-nm
, plasma-pa
, milou
, kscreen
, kdeconnect-kde
, wayland
}:

mkKdeDerivation {
  pname = "plasma-bigscreen";
  version = "6.4.80";

  src = fetchurl {
    url = "https://invent.kde.org/plasma/plasma-bigscreen/-/archive/253ee747be2304f20461aadd3c3a0e02d486f583/plasma-bigscreen-253ee747be2304f20461aadd3c3a0e02d486f583.tar.gz";
    hash = "sha256-SzHU0Bopawsy67JYw/DZuLSSZlMaXD+AvxA08seS4pE=";
  };

  patches = [ ./plasma-bigscreen-qmlprivate.patch ];

  postPatch = ''
    # ApplicationListModel iterates KServiceGroup entries but never checks
    # service->noDisplay(), so desktop files with NoDisplay=true (all the
    # kcm_* system-settings modules) appear in the bigscreen app launcher.
    # Add the same noDisplay guard that already exists at the group level.
    substituteInPlace containments/homescreen/plugin/applicationlistmodel.cpp \
      --replace-fail \
        'if (service->isApplication() && !blacklist.contains(service->desktopEntryName()) && service->showOnCurrentPlatform()' \
        'if (service->isApplication() && !service->noDisplay() && !blacklist.contains(service->desktopEntryName()) && service->showOnCurrentPlatform()'
  '';

  extraNativeBuildInputs = [ pkg-config ];

  extraBuildInputs = [
    qtsvg
    qtdeclarative
    qtwayland
    qtmultimedia
    qtwebengine
    bluez-qt
    ki18n
    kirigami
    kcmutils
    kglobalaccel
    knotifications
    kio
    kwindowsystem
    ksvg
    kdbusaddons
    kiconthemes
    libplasma
    plasma-activities
    plasma-activities-stats
    plasma-nano
    plasma-nm
    plasma-pa
    milou
    kscreen
    kdeconnect-kde
    wayland
  ];

  postInstall = ''
        # Create the session startup script that kwin_wayland uses as --exit-with-session.
        # When this process exits, kwin_wayland (and thus the whole session) exits.
        # plasma-bigscreen-common-env is sourced again here to restore QT_QPA_PLATFORMTHEME=KDE
        # for plasmashell (it was overridden to 'generic' in plasma-bigscreen-wayland to protect
        # kwin_wayland from the Qt 6.10.1 null-platform-theme crash; plasmashell needs KDE theme).
        # PLASMA_DEFAULT_SHELL is already in the environment (inherited from plasma-bigscreen-wayland).
        # Fix relative path to plasma-bigscreen-envmanager in the CMake-generated common-env script
        substituteInPlace $out/bin/plasma-bigscreen-common-env \
          --replace-fail 'plasma-bigscreen-envmanager' "$out/bin/plasma-bigscreen-envmanager"

        mkdir -p $out/libexec
        cat > $out/libexec/startplasma-waylandsession << EOF
    #!/bin/sh
    . $out/bin/plasma-bigscreen-common-env
    dbus-update-activation-environment --systemd --all
    exec ${plasma-workspace}/bin/plasmashell
    EOF
        chmod +x $out/libexec/startplasma-waylandsession

        # Rewrite the session script with absolute paths since SDDM's env may not
        # have plasma-workspace or plasma-bigscreen in PATH, and cmake left relative paths.
        # QT_QPA_PLATFORMTHEME=generic is set here to protect kwin_wayland from a crash:
        # KWin's own QPA plugin requests the 'kde' platform theme, but QKdeTheme::createKdeTheme()
        # returns null during cold initialization (Qt 6.10.1 + KWin 6.5.5), causing a null
        # pointer dereference in QStyleHintsPrivate::update(). The 'generic' theme is safe for
        # kwin itself. startplasma-waylandsession overrides this to KDE for plasmashell.
        cat > $out/bin/plasma-bigscreen-wayland << EOF
    #!/bin/sh
    . $out/bin/plasma-bigscreen-common-env
    # Add plasma-bigscreen's own share directory to XDG_DATA_DIRS so that plasmashell
    # can find the org.kde.plasma.bigscreen corona/KPackage installed there.
    export XDG_DATA_DIRS="$out/share:''${XDG_DATA_DIRS}"
    # Add plasma-bigscreen's QML modules so plasmashell can load org.kde.bigscreen,
    # plus the system profile QML path for packages in environment.systemPackages
    # (e.g. kdeconnect-kde provides org.kde.kdeconnect used by the homescreen applet).
    export QML2_IMPORT_PATH="$out/lib/qt-6/qml:${qtmultimedia}/lib/qt-6/qml:/run/current-system/sw/lib/qt-6/qml"
    # Add plasma-bigscreen's plugin directory so plasmashell can load the
    # org.kde.bigscreen.homescreen Plasma applet plugin (registers org.kde.private.biglauncher).
    export QT_PLUGIN_PATH="$out/lib/qt-6/plugins:''${QT_PLUGIN_PATH}"
    # Switch from dbus-run-session's isolated bus to the systemd user bus so that
    # org.freedesktop.systemd1 is accessible for plasma_session's systemd boot mode.
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\$(id -u)/bus
    # Propagate all env vars (including PLASMA_DEFAULT_SHELL, XDG_DATA_DIRS with
    # plasma-bigscreen share, and QT_QPA_PLATFORMTHEME=KDE) to systemd's activation
    # environment BEFORE overriding QT_QPA_PLATFORMTHEME below, so that
    # plasma-plasmashell.service (started by systemd) inherits the correct values.
    dbus-update-activation-environment --systemd --all
    # Override QT_QPA_PLATFORMTHEME=KDE set by common-env: KWin's own QPA plugin
    # requests the 'kde' theme, but QKdeTheme::createKdeTheme() returns null during
    # cold initialization (Qt 6.10.1 + KWin 6.5.5), causing a null pointer dereference
    # in QStyleHintsPrivate::update(). The 'generic' theme is safe for kwin itself.
    # plasma-plasmashell.service already received QT_QPA_PLATFORMTHEME=KDE above.
    export QT_QPA_PLATFORMTHEME=generic
    exec ${plasma-workspace}/bin/startplasma-wayland --xwayland --libinput --exit-with-session=$out/libexec/startplasma-waylandsession
    EOF
  '';

  passthru.providedSessions = [ "plasma-bigscreen-wayland" ];

  meta = with lib; {
    description = "KDE Plasma interface designed for large screens and TV displays";
    homepage = "https://plasma-bigscreen.org/";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}

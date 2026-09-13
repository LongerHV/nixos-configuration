{ lib
, python3Packages
, gobject-introspection
, wrapGAppsNoGuiHook
, glib
, android-tools
, waydroid
}:

python3Packages.buildPythonApplication {
  pname = "waydroid-mpris-spotify";
  version = "0.1.0";
  pyproject = false;

  src = ./waydroid-mpris-spotify.py;
  dontUnpack = true;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsNoGuiHook
  ];

  buildInputs = [ glib ];

  dependencies = with python3Packages; [
    dbus-python
    pygobject3
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/waydroid-mpris-spotify
    runHook postInstall
  '';

  # Let the python wrapper carry the GI typelib paths too, instead of wrapping twice.
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${lib.makeBinPath [ android-tools waydroid ]}
    )
  '';

  meta = {
    description = "Expose Spotify running inside Waydroid as an MPRIS player";
    mainProgram = "waydroid-mpris-spotify";
    platforms = lib.platforms.linux;
  };
}

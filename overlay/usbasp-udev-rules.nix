{ stdenv, pkgs, ... }:

let
  udevFileName = "99-usbasp.rules";
  udevFile = pkgs.writeTextFile {
    name = udevFileName;
    text = ''
      # USBasp Programmer rules http://www.fischl.de/usbasp/
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="uucp", MODE="0666"
    '';
  };
in
stdenv.mkDerivation {
  name = "usbasp-udev-rules";
  dontBuild = true;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -D ${udevFile} $out/lib/udev/rules.d/${udevFileName}
    runHook postInstall
  '';
}

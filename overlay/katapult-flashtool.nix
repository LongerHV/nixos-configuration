{ lib, stdenvNoCC, fetchFromGitHub, python3, ... }:

stdenvNoCC.mkDerivation {
  pname = "katapult-flashtool";
  version = "0-unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "Arksine";
    repo = "katapult";
    rev = "3b973a485388b4ef0f9efef46f78152e302aea8e";
    hash = "sha256-iC3ypiuSzZ0Yy/RoWHOWCp/7vUL38FmLDTbdSClxynA=";
  };

  buildInputs = [ (python3.withPackages (ps: [ ps.pyserial ])) ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 scripts/flashtool.py $out/bin/katapult-flashtool
    runHook postInstall
  '';

  meta = {
    description = "Katapult bootloader flash tool (serial/USB/CAN)";
    homepage = "https://github.com/Arksine/katapult";
    license = lib.licenses.gpl3Only;
    mainProgram = "katapult-flashtool";
    platforms = lib.platforms.linux;
  };
}

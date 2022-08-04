{ lib, fetchzip, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "invoiceninja";
  version = "5.5.6";

  src = fetchzip {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}.zip";
    sha256 = "sha256-DBnaqijxcYtH7kDa0dSPNy7W04Fjk8LFbPmdL3HIgpI=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/
    cp -r . $out/
  '';
}

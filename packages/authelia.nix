{ stdenv, lib, fetchzip, autoPatchelfHook, ... }:

stdenv.mkDerivation rec {
  pname = "authelia";
  version = "v4.35.6";

  src = fetchzip {
    url = "https://github.com/${pname}/${pname}/releases/download/${version}/${pname}-${version}-linux-amd64.tar.gz";
    sha256 = "pNuE/RD7R7CZYT9t24nAULDho0H2al4L+WeUSuyYcJU=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    install -m 755 -D ${pname}-linux-amd64 $out/bin/authelia
  '';

  meta = {
    homepage = "https://www.authelia.com";
    description = ''
      Authelia is a 2FA & SSO authentication server which is dedicated to the security of applications and users.
    '';
    platforms = lib.platforms.linux;
  };
}

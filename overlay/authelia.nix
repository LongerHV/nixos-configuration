{ stdenv, lib, fetchzip, autoPatchelfHook, ... }:

stdenv.mkDerivation rec {
  pname = "authelia";
  version = "4.37.2";

  src = fetchzip {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}-v${version}-linux-amd64.tar.gz";
    sha256 = "sha256-2ap1b2otBg2uRjb9cAWmb1B3Ql+7AJy9fdeldABfJyk=";
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

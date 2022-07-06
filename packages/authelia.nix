{ stdenv, lib, fetchzip, autoPatchelfHook, ... }:

let
  pname = "authelia";
  version = "4.36.2";
in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchzip {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}-v${version}-linux-amd64.tar.gz";
    sha256 = "l7VKO28mcGqho2WiMzvRSmQ9PZaKKZs+vLOigVhqCjk=";
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

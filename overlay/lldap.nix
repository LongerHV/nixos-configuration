{ stdenv, fetchurl, autoPatchelfHook, ... }:

stdenv.mkDerivation rec {
  pname = "lldap-bin";
  version = "0.4.2";

  src = fetchurl {
    url = "https://github.com/lldap/lldap/releases/download/v0${version}/amd64-lldap.tar.gz";
    sha256 = "sha256-x/7ILQ9/rI5PMn7mVNte07Pf+85t/I+9iWIyqkxMWfU=";
  };

  outputs = [ "out" "web" ];

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    install -m755 -D lldap $out/bin/lldap
    install -m755 -D lldap_set_password $out/bin/lldap_set_password
    install -m755 -D migration-tool $out/bin/migration-tool
    cp -R app $web
  '';
}

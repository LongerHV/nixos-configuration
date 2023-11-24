{ stdenv, autoPatchelfHook, fetchurl, ... }:

let
  version = "0.1.11";
in
stdenv.mkDerivation {
  pname = "ollama-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/jmorganca/ollama/releases/download/v${version}/ollama-linux-amd64";
    hash = "sha256-cLXl0Gg870TCkKbq0JA/ptB1BK9naYtBHVkjSrE6P94=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/ollama
    chmod +x $out/bin/ollama
  '';

  nativeBuildInputs = [
    autoPatchelfHook
  ];
}

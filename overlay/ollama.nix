{ stdenv, autoPatchelfHook, fetchurl, ... }:

let
  version = "0.1.10";
in
stdenv.mkDerivation {
  pname = "ollama-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/jmorganca/ollama/releases/download/v${version}/ollama-linux-amd64";
    hash = "sha256-FcC+R2RBU2wtFqDwbN8X1N4/8PaGwpFUtcxrx096t7M=";
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

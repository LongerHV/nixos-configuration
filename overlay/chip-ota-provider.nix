{ stdenv, fetchurl, autoPatchelfHook, libnl, ... }:

let
  version = "2025.9.0";
  sources = {
    x86_64-linux = {
      url = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/${version}/chip-ota-provider-app-x86-64";
      hash = "sha256-RVDfevZSnkYgRj0cASf4MOwkBMgXrUxjQ7KeMs7AFE4=";
    };
    aarch64-linux = {
      url = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/${version}/chip-ota-provider-app-aarch64";
      hash = "sha256-4GirbEBQ4j6qbM2pv37M3Et5KiUU4QmMvBK0FM1kqn4=";
    };
  };
  source = sources.${stdenv.hostPlatform.system}
    or (throw "chip-ota-provider: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "chip-ota-provider";
  inherit version;

  src = fetchurl { inherit (source) url hash; };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib libnl ];

  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/chip-ota-provider-app
  '';
}

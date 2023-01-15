{ pkgs
, fetchFromGitHub
, fetchYarnDeps
, yarn2nix-moretea
, makeWrapper
, nodejs ? pkgs.nodejs-16_x
, ...
}:

let
  version = "2.1.1";
  src = fetchFromGitHub {
    owner = "Lissy93";
    repo = "dashy";
    rev = version;
    sha256 = "sha256-8+J0maC8M2m+raiIlAl0Bo4HOvuuapiBhoSb0fM8f9M=";
  };
  yarn2nix = yarn2nix-moretea.override {
    inherit nodejs;
    inherit (nodejs.pkgs) yarn;
  };
in
yarn2nix.mkYarnPackage {
  pname = "dashy";
  inherit version src;

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    sha256 = "sha256-RxreSjhbWovPbqjK6L9GdIEhH4uVY+RvWyJYwIytn4g=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    makeWrapper ${nodejs}/bin/node $out/bin/dashy --add-flags $out/libexec/Dashy/deps/Dashy/server.js
  '';
}

{ pkgs
, fetchFromGitHub
, fetchYarnDeps
, makeWrapper
, nodejs-16_x
, yarn2nix-moretea
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
  nodejs = nodejs-16_x;
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
  patches = [ ./dashy.patch ];

  # https://stackoverflow.com/questions/74726224/opensslerrorstack-error03000086digital-envelope-routinesinitialization-e
  NODE_OPTIONS = "--openssl-legacy-provider";


  buildPhase = ''
    export HOME=$(mktemp -d)
    # https://stackoverflow.com/questions/49709252/no-postcss-config-found
    echo 'module.exports = {};' > postcss.config.js
    yarn --offline build --mode production
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/dashy" \
      --add-flags "$out/libexec/Dashy/deps/Dashy/server.js"
  '';
}

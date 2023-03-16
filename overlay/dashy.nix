{ pkgs
, fetchFromGitHub
, fetchYarnDeps
, makeWrapper
, nodejs-16_x
, yarn2nix-moretea
, ...
}:

let
  version = "baf9b5a66ed2ca39ba7f0d0ca95449b1e5f92764";
  src = fetchFromGitHub {
    owner = "Lissy93";
    repo = "dashy";
    rev = version;
    sha256 = "sha256-0VDu1a+Opt/C2SWiT1hHm+gn7WQ/dnZJHRwgw0kgDa4=";
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
    sha256 = "sha256-0OuvjxsLNvuwXeVxNUqp+NlfKaH13WAUrbfUMpZ5VT4=";
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

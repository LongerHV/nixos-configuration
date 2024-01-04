{ buildNpmPackage, fetchFromGitHub, nodejs, ... }:

let
  pname = "homepage";
  version = "0.8.4";
in
buildNpmPackage {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "gethomepage";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-WjyOpR8DcjlJJgUkWortc0ApgpusknTSeVQlSa5rCRQ=";
  };

  npmDepsHash = "sha256-RC2Y4XZqO+mLEKQxq+j2ukZYi/uu9XIjYadxek9P+SM=";

  NEXT_TELEMETRY_DISABLED = "1";

  buildPhase = ''
    runHook preBuild

    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/app/.next
    cp package.json next.config.js $out/app
    cp -r public $out/app/public
    cp -r .next/standalone/. $out/app/
    cp -r .next/static $out/app/.next

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/homepage" \
      --add-flags "$out/app/server.js"
  '';
}

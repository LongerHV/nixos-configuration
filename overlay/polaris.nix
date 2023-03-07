{ buildGoModule, fetchFromGitHub, packr, ... }:

buildGoModule rec {
  pname = "polaris-scan";
  version = "7.3.2";

  src = fetchFromGitHub {
    owner = "FairwindsOps";
    repo = "polaris";
    rev = version;
    sha256 = "sha256-LteclhYNMFNuGjFSuhPuY9ZA1Vlq4DPdcCGAQaujwh8=";
  };
  vendorSha256 = "sha256-3htwwRkUOf8jLyLfRlhcWhftBImmcUglc/PP/Yk2oF0=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.Commit=${version}"
  ];

  preBuild = ''
    ${packr}/bin/packr2 -v --ignore-imports
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/polaris help
    $out/bin/polaris version | grep 'Polaris version:${version}'

    runHook postInstallCheck
  '';
}

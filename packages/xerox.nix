{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  pname = "xerox-generic-driver";
  version = "5.852.0.0";

  src = fetchzip {
    url = "https://download.support.xerox.com/pub/drivers/B310/drivers/linux/ar/B305_B315_${version}_PPD.zip";
    sha256 = "sha256-qnuAVaixw4zdf+djyF6IlYB+ekNu4mkTf+e2AQ0t7Ws=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/share/cups/model/XEROX
    cp Linux/English/*.ppd $out/share/cups/model/XEROX
  '';
}

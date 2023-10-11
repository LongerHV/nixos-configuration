{ buildGoModule, fetchFromGitHub, ... }:

let
  version = "v0.2.364";
in
buildGoModule {
  pname = "templ";
  inherit version;
  src = fetchFromGitHub {
    owner = "a-h";
    repo = "templ";
    rev = version;
    sha256 = "sha256-ieTfgvPu+JKMLi6EvdWYqC2n4TKFJjmQ3TBLK/e9zZ0=";
  };
  vendorHash = "sha256-7QYF8BvLpTcDstkLWxR0BgBP0NUlJ20IqW/nNqMSBn4=";
  subPackages = "./cmd/templ";
}

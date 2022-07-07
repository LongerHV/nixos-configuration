{ stdenvNoCC, fetchFromGitHub, ... }:

stdenvNoCC.mkDerivation rec {
  pname = "zsh-vim-mode";
  version = "unstable-2021-03-21";

  strictDeps = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/zsh-vim-mode
    cp zsh-vim-mode.plugin.zsh $out/share/zsh-vim-mode
  '';

  src = fetchFromGitHub {
    owner = "softmoth";
    repo = "${pname}";
    rev = "1f9953b7d6f2f0a8d2cb8e8977baa48278a31eab";
    sha256 = "1i79rrv22mxpk3i9i1b9ykpx8b4w93z2avck893wvmaqqic89vkb";
  };
}

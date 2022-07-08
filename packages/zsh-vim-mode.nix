{ zsh-vim-mode, ... }:
{ stdenvNoCC, fetchFromGitHub, ... }:

stdenvNoCC.mkDerivation rec {
  pname = "zsh-vim-mode";
  version = "unstable";

  strictDeps = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/zsh-vim-mode
    cp zsh-vim-mode.plugin.zsh $out/share/zsh-vim-mode
  '';

  src = zsh-vim-mode;
}

final: prev:

{
  gnome = prev.gnome.overrideScope' (gfinal: gprev: {
    gnome-terminal = gprev.gnome-terminal.overrideAttrs (attrs: rec {
      pname = "gnome-terminal";
      version = "3.44.1";
      src = builtins.fetchTarball {
        url = "https://download.gnome.org/sources/${pname}/${prev.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
        sha256 = "1fzl398gc9vw3072jg5f4vcgxisfh9yg52fgqd9m77g4gf582s3x";
      };
      patches = [
        (builtins.fetchurl {
          url = "https://aur.archlinux.org/cgit/aur.git/plain/transparency.patch?h=gnome-terminal-transparency";
          sha256 = "0hjfyl34s9c5b1ns4yfsrl9gc86gddapap0p56hfg9200xp3ap89";
        })
      ];
    });
  });
  authelia = prev.callPackage ./authelia.nix { };
  zsh-z = prev.zsh-z.overrideAttrs (attrs: rec {
    pname = "zsh-z";
    version = "unstable-2022-06-30";

    src = prev.pkgs.fetchFromGitHub {
      owner = "agkozak";
      repo = pname;
      rev = "aaafebcd97424c570ee247e2aeb3da30444299cd";
      sha256 = "9Wr4uZLk2CvINJilg4o72x0NEAl043lP30D3YnHk+ZA=";
    };
  });
  zsh-vim-mode = prev.callPackage ./zsh-vim-mode.nix { };
}

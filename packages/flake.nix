{
  description = "Personal package overlay";
  inputs = {
    zsh-vim-mode = {
      url = "github:softmoth/zsh-vim-mode";
      flake = false;
    };
    zsh-z = {
      url = "github:agkozak/zsh-z";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, zsh-vim-mode, zsh-z }: {
    overlay = final: prev: {
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
      authelia = prev.callPackage ./authelia.nix prev;
      zsh-z = prev.zsh-z.overrideAttrs (attrs: rec {
        pname = "zsh-z";
        version = "unstable";
        src = zsh-z;
      });
      zsh-vim-mode = prev.callPackage ./zsh-vim-mode.nix inputs prev;
      invoiceninja = prev.callPackage ./invoiceninja.nix prev;
      qmk = prev.callPackage ./qmk.nix prev;
      xerox-generic-driver = prev.callPackage ./xerox.nix prev;
    };
  };
}

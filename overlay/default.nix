final: prev: {
  templ = prev.callPackage ./templ.nix prev;
  xerox-generic-driver = prev.callPackage ./xerox.nix prev;

  # Waiting for https://github.com/mhartington/oceanic-next/pull/123
  nvimPlugins = prev.nvimPlugins // {
    oceanic-next = prev.nvimPlugins.oceanic-next.overrideAttrs (old: {
      patches = [
        (prev.fetchpatch {
          url = "https://github.com/mhartington/oceanic-next/commit/5fe2d5cc25f66b9d633a71e06c05c6c38e9f1671.diff";
          hash = "sha256-xERdAsUf1AcdFJueXljF6OhyT5LHdXQvQvZi5mwCNVw=";
        })
      ];
    });
  };

  # Workaround for "undefined reference to `__exidx_start'" error
  inherit (prev.unstable) klipper-firmware;

  zsh-z = prev.zsh-z.overrideAttrs (attrs: rec {
    pname = "zsh-z";
    version = "unstable-2023-01-27";
    src = prev.fetchFromGitHub {
      owner = "agkozak";
      repo = pname;
      rev = "c28d8f5f16424c7855a627f50ff986de952d8d2d";
      sha256 = "sha256-O8wP6XUR3OgMLgloiM/C8c3k/v85+U+QwtxjR6ePFBk=";
    };
  });
  nierWallpaper = builtins.fetchurl {
    url = "https://images6.alphacoders.com/655/655990.jpg";
    sha256 = "b09b411a9c7fc7dc5be312ca9e4e4b8ee354358daa792381f207c9f4946d95fe";
  };
}

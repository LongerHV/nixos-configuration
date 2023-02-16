final: prev: {
  authelia = prev.callPackage ./authelia.nix prev;
  # Must wait for Dashy 2.1.2 (now it requires `yarn build` after config changes)
  # dashy = prev.callPackage ./dashy.nix prev;
  xerox-generic-driver = prev.callPackage ./xerox.nix prev;

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
}

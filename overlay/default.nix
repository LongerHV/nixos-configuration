final: prev: {
  authelia = prev.callPackage ./authelia.nix prev;
  # Must wait for Dashy 2.1.2 (now it requires `yarn build` after config changes)
  # dashy = prev.callPackage ./dashy.nix prev;
  xerox-generic-driver = prev.callPackage ./xerox.nix prev;

  zsh-z = prev.zsh-z.overrideAttrs (attrs: rec {
    pname = "zsh-z";
    version = "unstable-2022-10-27";
    src = prev.fetchFromGitHub {
      owner = "agkozak";
      repo = pname;
      rev = "82f5088641862d0e83561bb251fb60808791c76a";
      sha256 = "sha256-6BNYzfTcjWm+0lJC83IdLxHwwG4/DKet2QNDvVBR6Eo=";
    };
  });
}

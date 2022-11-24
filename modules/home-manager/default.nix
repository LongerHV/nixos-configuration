{
  default = { lib, ... }: {
    home = rec {
      username = lib.mkDefault "mmieszczak";
      homeDirectory = lib.mkDefault "/home/${username}";
    };
  };
  nonNixos = import ./non-nixos.nix;
}

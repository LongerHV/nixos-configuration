{
  default = { lib, ... }: {
    home = rec {
      username = lib.mkDefault "longer";
      homeDirectory = lib.mkDefault "/home/${username}";
      stateVersion = lib.mkDefault "21.11";
    };
  };
  myHome = import ./myHome;
}

_:

{
  imports = [
    ./config/cli-packages.nix
    ./config/devops.nix
    ./config/gnome.nix
  ];

  home = rec {
    username = "mmieszczak";
    homeDirectory = "/home/${username}";
    stateVersion = "22.05";
  };

  myHome = {
    nonNixos.enable = true;
  };
}

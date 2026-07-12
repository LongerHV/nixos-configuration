{
  default = { config, lib, ... }: {
    home = rec {
      username = lib.mkDefault "longer";
      homeDirectory = lib.mkDefault "/home/${username}";
      stateVersion = lib.mkDefault "21.11";
    };
    xdg = {
      enable = lib.mkDefault true;
      localBinInPath = true;
      userDirs = {
        enable = lib.mkDefault true;
        setSessionVariables = lib.mkDefault false;
        createDirectories = lib.mkDefault true;
        desktop = lib.mkDefault "${config.home.homeDirectory}/Pulpit";
        documents = lib.mkDefault "${config.home.homeDirectory}/Dokumenty";
        download = lib.mkDefault "${config.home.homeDirectory}/Pobrane";
        music = lib.mkDefault "${config.home.homeDirectory}/Muzyka";
        pictures = lib.mkDefault "${config.home.homeDirectory}/Obrazy";
        projects = lib.mkDefault "${config.home.homeDirectory}/Projekty";
        publicShare = lib.mkDefault "${config.home.homeDirectory}/Publiczny";
        templates = lib.mkDefault "${config.home.homeDirectory}/Szablony";
        videos = lib.mkDefault "${config.home.homeDirectory}/Wideo";
      };
    };
  };
  myHome = import ./myHome;
}

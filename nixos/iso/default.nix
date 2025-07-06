{
  mySystem = {
    user = "nixos";
    home-manager = {
      enable = true;
      home = ./home.nix;
    };
  };
  programs.gnome-terminal.enable = true;
}

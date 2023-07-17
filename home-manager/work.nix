{
  home = rec {
    username = "mmieszczak";
    homeDirectory = "/home/${username}";
    stateVersion = "22.05";
  };

  myHome = {
    nonNixos.enable = true;
    nonNixos.nix.substituters = [ "nasgul" "helix" ];
    gnome.enable = true;
    devops.enable = true;
    cli.personalGitEnable = false;
    tmux.enable = true;
    zsh.enable = true;
    helix.enable = true;
    neovim = {
      enable = true;
      enableLSP = true;
    };
  };

  # Workaround for freezing during activity switching on Ubuntu
  dconf.settings."org/gnome/desktop/interface".enable-animations = false;
}

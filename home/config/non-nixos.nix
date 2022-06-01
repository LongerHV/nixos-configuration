{ pkgs, ... }:

{
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.packages = with pkgs; [
    hostname
    unstable.home-manager
    # This must be here, enable option below does not ensure that nix is installed
    nix
  ];

  nix = {
    enable = true;
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

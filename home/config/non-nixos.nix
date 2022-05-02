{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hostname
    unstable.home-manager
    # This must be here, enable option below does not ensure that nix is installed
    unstable.nix
  ];

  nix = {
    enable = true;
    package = pkgs.unstable.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

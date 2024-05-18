{ config, lib, pkgs, ... }:

{
  imports = [ ./plugins ];

  options.myHome.neovim = with lib; {
    enable = mkEnableOption "neovim";
    enableLSP = mkEnableOption "enableLSP";
  };

  config = lib.mkIf config.myHome.neovim.enable {
    home.sessionVariables.EDITOR = "nvim";
    programs.xenon = {
      enable = true;
      package = pkgs.unstable.neovim-unwrapped;
      aliases = [ "nvim" "vim" "vi" ];
      initFiles = [
        ./init.lua
        ./theme.lua
        ./keymaps.lua
      ];
      extraPackages = with pkgs; [
        nodePackages.npm
        nodePackages.neovim
      ];
    };
  };
}

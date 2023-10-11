{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.neovim;
in
{
  options.myHome.neovim = with lib; {
    enable = mkEnableOption "neovim";
    enableLSP = mkEnableOption "enableLSP";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = lib.mkMerge [
      {
        enable = true;
        vimAlias = true;
        viAlias = true;
        withNodeJs = true;
        withPython3 = true;
        withRuby = false;
        extraLuaConfig = ''
          require("config")
        '';
        plugins = with pkgs.nvimPlugins; [
          indent-blankline
          mini
          nvim-ts-rainbow
          oceanic-next
          pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars
          plenary
          telescope
          telescope-file-browser
        ];
        extraPackages = with pkgs; [
          nodePackages.npm
          nodePackages.neovim
          ripgrep
          fd
        ];
      }

      (lib.mkIf cfg.enableLSP {
        plugins = with pkgs.nvimPlugins; [
          {
            plugin = nvim-lspconfig;
            type = "lua";
            config =
              let
                lspServers = pkgs.writeText "lsp_servers.json" (builtins.toJSON (import ./lsp_servers.nix { inherit pkgs; }));
              in
              ''
                require("config.languages").setup_servers("${lspServers}")
              '';
          }
        ];
        extraPackages = with pkgs; [
          (nodePackages.pyright.override {
            inherit (unstable.nodePackages.pyright) src version name;
          })
          unstable.lua-language-server
          unstable.nil
          unstable.gopls
          nixpkgs-fmt
          templ
        ];
      })
    ];

    xdg.configFile."nvim/lua/config" = {
      recursive = true;
      source = ./config;
    };
  };
}

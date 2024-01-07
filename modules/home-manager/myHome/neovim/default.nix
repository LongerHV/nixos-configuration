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
    home.sessionVariables = {
      EDITOR = "${config.home.profileDirectory}/bin/nvim";
    };
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
          oceanic-next
          pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars
          plenary
          telescope
          devicons
          gitsigns
          dressing
          gen
          fidget
          oil
          pkgs.vimPlugins.vim-sleuth
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
          (python3.withPackages (ps: with ps; [
            setuptools # Required by pylama for some reason
            pylama
            black
            isort
            yamllint
          ]))
          (nodePackages.pyright.override {
            inherit (unstable.nodePackages.pyright) src version name;
          })
          unstable.lua-language-server
          unstable.nil
          unstable.gopls
          nixpkgs-fmt
          templ
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
          nodePackages.dockerfile-language-server-nodejs
          nodePackages.vscode-langservers-extracted
          nodePackages.typescript-language-server
          nodePackages.prettier
          terraform-ls
          tflint
          efm-langserver
          taplo
        ];
      })
    ];

    xdg.configFile."nvim/lua/config" = {
      recursive = true;
      source = ./config;
    };
  };
}

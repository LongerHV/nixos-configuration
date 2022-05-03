{ pkgs, ... }:

let
  TSCompiler = pkgs.gcc;
in
{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    extraConfig = ''
      let mapleader=" "

      lua <<EOF
        require("config.general")
        require("plugins")
        require("config.theme")
        require("config.remaps")

        -- Set compiler for treesitter to use
        local status, ps_install = pcall(require, "nvim-treesitter.install")
        if(status) then
          ps_install.compilers = { "${TSCompiler}/bin/gcc" }
        end
      EOF
    '';
    plugins = with pkgs.vimPlugins; [
      packer-nvim
    ];
    extraPackages = with pkgs; [
      # Essentials
      nodePackages.npm
      nodePackages.neovim

      # Python
      (python3.withPackages (ps: with ps; [
        flake8
        autopep8
        isort
        yamllint
        debugpy
      ]))
      nodePackages.pyright

      # Lua
      sumneko-lua-language-server
      selene
      stylua

      # Nix
      statix
      rnix-lsp

      # C, C++
      clang-tools
      cppcheck

      # Shell scripting
      shfmt
      shellcheck
      shellharden

      # Additional
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.vscode-json-languageserver
      nodePackages.markdownlint-cli
      nodePackages.prettier
      taplo-lsp
      texlab
      codespell

      # Treesitter parser compilation
      TSCompiler

      # Telescope dependencies
      ripgrep
      fd
    ];
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = ../../dotfiles/nvim;
    };
  };
}

{ pkgs, ... }:

let
  # Compiler for treesitter
  TSCompiler = pkgs.unstable.gcc;
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
        local status, ts_install = pcall(require, "nvim-treesitter.install")
        if(status) then
          ts_install.compilers = { "${TSCompiler}/bin/gcc" }
        end
      EOF
    '';
    plugins = with pkgs.unstable.vimPlugins; [
      packer-nvim
    ];
    extraPackages = with pkgs.unstable; [
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

      # JavaScript (tsserver is not working)
      nodePackages.prettier
      nodePackages.eslint
      # nodePackages.typescript
      # nodePackages.typescript-language-server

      # Go
      go
      gopls

      # Additional
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.vscode-json-languageserver
      nodePackages.markdownlint-cli
      taplo-cli
      texlab
      codespell

      # Telescope dependencies
      ripgrep
      fd
    ] ++ [ TSCompiler ];
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = ../../dotfiles/nvim;
    };
  };
}

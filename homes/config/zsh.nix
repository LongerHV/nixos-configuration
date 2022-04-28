{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    zsh-syntax-highlighting
    zsh-history-substring-search
    /* zsh-vi-mode */ /* https://github.com/jeffreytse/zsh-vi-mode/issues/122 */
    zsh-nix-shell
    zsh-you-should-use
    zsh-z
    spaceship-prompt
  ];

  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
    };
    shellAliases = {
      ll = "ls -lh --color=auto";
      la = "ls -lah --color=auto";
    };
    initExtraBeforeCompInit = ''
      # Completion
      zstyle ':completion:*' menu yes select

      # Edit line in editor
      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line

      # Prompt
      source ${pkgs.spaceship-prompt}/lib/spaceship-prompt/spaceship.zsh
      autoload -U promptinit; promptinit

      # Plugins
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      # source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.zsh
      source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
      # source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh

      # History search bindings
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';
    initExtra = ''
      # Source additional files
      for f in $HOME/.config/zsh/*; do source "$f"; done
    '';
    localVariables = {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=13,underline";
      ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
      KEYTIMEOUT = 1;
      ZSHZ_CASE = "smart";
      ZSHZ_ECHO = 1;
    };
    enableAutosuggestions = true;
    enableCompletion = true;
    plugins = [
      {
        name = "zsh-vim-mode";
        src = pkgs.fetchFromGitHub {
          owner = "softmoth";
          repo = "zsh-vim-mode";
          rev = "1f9953b7d6f2f0a8d2cb8e8977baa48278a31eab";
          sha256 = "1i79rrv22mxpk3i9i1b9ykpx8b4w93z2avck893wvmaqqic89vkb";
        };
      }
      {
        # Package available in nixpkgs is not up to date
        name = "zsh-z";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "b30bc6050e77abe30ce36761d18ed696e5410f16";
          sha256 = "05jjmqivib727pdvw95m5jrr4ag8x06y0hrr6ksnfq0ni8mgl9ad";
        };
      }
    ];
  };

  home.file = {
    ".config/zsh" = {
      recursive = true;
      source = ../../dotfiles/zsh;
    };
  };
}

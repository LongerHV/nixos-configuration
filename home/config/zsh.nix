{ pkgs, config, ... }:

{
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
    '';
    initExtra = ''
      # Source additional files
      for f in $HOME/.config/zsh/*.zsh; do source "$f"; done

      # History search bindings
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
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
    enableSyntaxHighlighting = true;
    plugins = [
      {
        name = "zsh-history-substring-search";
        file = "zsh-history-substring-search.zsh";
        src = "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
      }
      {
        name = "nix-shell";
        src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
      }
      {
        name = "you-should-use";
        src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
      }
      {
        /* https://github.com/jeffreytse/zsh-vi-mode/issues/122 */
        # ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.zsh
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
        # ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh
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

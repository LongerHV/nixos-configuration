{ pkgs, config, ... }:

{
  programs.command-not-found.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
    };
    shellAliases = {
      ll = "${pkgs.exa}/bin/exa -l --icons";
      la = "${pkgs.exa}/bin/exa -la --icons";
      ns = "sudo nixos-rebuild switch --flake .";
      hs = "home-manager switch --flake .";
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
        src = "${pkgs.zsh-vim-mode}/share/zsh-vim-mode";
      }
      {
        name = "zsh-z";
        src = "${pkgs.zsh-z}/share/zsh-z";
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

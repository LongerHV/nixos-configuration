{ config, lib, pkgs, ... }:

{
  options.myHome.zsh = with lib; {
    enable = mkEnableOption "zsh";
  };

  config = {
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
        hs = "home-manager switch --impure --flake .";
      };
      initExtraBeforeCompInit = ''
        # Completion
        zstyle ':completion:*' menu yes select

        # Prompt
        source ${pkgs.spaceship-prompt}/lib/spaceship-prompt/spaceship.zsh
        autoload -U promptinit; promptinit
      '';
      initExtra = ''
        source ${./kubectl.zsh}
        source ${./git.zsh}

        bindkey '^[[Z' reverse-menu-complete

        # Workaround for ZVM overwriting keybindings
        zvm_after_init_commands+=("bindkey '^[[A' history-substring-search-up")
        zvm_after_init_commands+=("bindkey '^[OA' history-substring-search-up")
        zvm_after_init_commands+=("bindkey '^[[B' history-substring-search-down")
        zvm_after_init_commands+=("bindkey '^[OB' history-substring-search-down")
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
      enableVteIntegration = true;
      historySubstringSearch = {
        enable = true;
        # searchUpKey = [ "^[[A" "^[OA" ];
        # searchDownKey = [ "^[[B" "^[OB" ];
      };
      plugins = [
        {
          name = "nix-shell";
          src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        }
        {
          name = "you-should-use";
          src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
        }
        {
          name = "zsh-vi-mode";
          src = "${pkgs.unstable.zsh-vi-mode}/share/zsh-vi-mode";
        }
        {
          name = "zsh-z";
          src = "${pkgs.zsh-z}/share/zsh-z";
        }
      ];
    };
    home.file.".config/spaceship.zsh".source = ./spaceship.zsh;
  };
}

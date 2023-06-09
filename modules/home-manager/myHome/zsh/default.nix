{ config, lib, pkgs, ... }:

{
  imports = [ ./starship.nix ];

  options.myHome.zsh = with lib; {
    enable = mkEnableOption "zsh";
  };

  config = lib.mkIf config.myHome.zsh.enable {
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
      '';
      initExtra = ''
        source ${./kubectl.zsh}
        source ${./git.zsh}

        bindkey '^[[Z' reverse-menu-complete
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
      historySubstringSearch.enable = true;
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
          name = "zsh-vi-mode";
          src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
        }
        {
          name = "zsh-z";
          src = "${pkgs.zsh-z}/share/zsh-z";
        }
      ];
    };
  };
}

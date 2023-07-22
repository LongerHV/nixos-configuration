{ pkgs, ... }:

{
  imports = [ ./prettier.nix ./python.nix ./webdev.nix ./markdown.nix ];
  programs.helix.languages = with pkgs; {
    language-server = {
      gopls.command = "${gopls}/bin/gopls";
      nil = {
        command = "${nil}/bin/nil";
        config = {
          nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
          nil.formatting.command = [ "${nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
      };
      bashls = {
        command = "${nodePackages.bash-language-server}/bin/bash-language-server";
        args = [ "start" ];
      };
      taplo = {
        command = "${taplo-cli}/bin/taplo";
        args = [ "lsp" "stdio" ];
      };
    };
    language = [
      {
        name = "go";
        scope = "source.go";
        injection-regex = "go";
        file-types = [ "go" ];
        roots = [ "go.work" "go.mod" ];
        auto-format = true;
        comment-token = "//";
        language-servers = [ "gopls" ];
        indent = { tab-width = 4; unit = "\t"; };
      }
      {
        name = "nix";
        scope = "source.nix";
        injection-regex = "nix";
        file-types = [ "nix" ];
        shebangs = [ ];
        roots = [ ];
        comment-token = "#";
        indent = { tab-width = 2; unit = "  "; };
        language-servers = [ "nil" ];
        auto-format = true;
      }
      {
        name = "bash";
        scope = "source.bash";
        injection-regex = "(shell|bash|zsh|sh)";
        file-types = [ "sh" "bash" "zsh" ".bash_login" ".bash_logout" ".bash_profile" ".bashrc" ".profile" ".zshenv" ".zlogin" ".zlogout" ".zprofile" ".zshrc" "APKBUILD" "PKGBUILD" "eclass" "ebuild" "bazelrc" ".bash_aliases" ];
        shebangs = [ "sh" "bash" "dash" "zsh" ];
        roots = [ ];
        comment-token = "#";
        language-servers = [ "bashls" ];
        indent = { tab-width = 2; unit = "  "; };
      }
      {
        name = "toml";
        scope = "source.toml";
        injection-regex = "toml";
        file-types = [ "toml" "poetry.lock" ];
        roots = [ ];
        comment-token = "#";
        language-servers = [ "taplo" ];
        indent = { tab-width = 2; unit = "  "; };
      }
    ];
  };
}

{ pkgs, ... }:

{
  programs.helix.languages = {
    language-server = with pkgs; {
      pyright = {
        command = "${nodePackages.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
        config = { };
      };
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
      typescript-language-server = {
        command = "${nodePackages.typescript-language-server}/bin/typescript-language-server";
        args = [ "--stdio" ];
        config.tsserver.path = "${pkgs.nodePackages.typescript}/bin/tsserver";
      };
      volar = {
        command = "${nodePackages.volar}/bin/vue-language-server";
        args = [ "--stdio" ];
        config.typescript.tsdk = "${nodePackages.typescript}/lib/node_modules/typescript/lib";
      };
      taplo = {
        command = "${taplo-cli}/bin/taplo";
        args = [ "lsp" "stdio" ];
      };
    };
    language = with pkgs;[
      {
        name = "python";
        file-types = [ "py" ];
        scope = "source.python";
        roots = [ "pyproject.toml" ];
        comment-token = "#";
        language-servers = [ "pyright" ];
        formatter = {
          command = "${python3Packages.black}/bin/black";
          args = [ "--quiet" "-" ];
        };
        indent = { tab-width = 4; unit = "    "; };
      }
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
        name = "javascript";
        scope = "source.js";
        injection-regex = "(js|javascript)";
        language-id = "javascript";
        file-types = [ "js" "mjs" "cjs" ];
        shebangs = [ "node" ];
        roots = [ ];
        comment-token = "//";
        language-servers = [ "typescript-language-server" ];
        indent = { tab-width = 2; unit = "  "; };

      }
      {
        name = "vue";
        scope = "source.vue";
        injection-regex = "vue";
        file-types = [ "vue" ];
        roots = [ "package.json" "vue.config.js" ];
        indent = { tab-width = 2; unit = "  "; };
        language-servers = [ "volar" ];
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

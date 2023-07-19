{ pkgs, ... }:

let
  vscodeLSP = pkgs.nodePackages.vscode-langservers-extracted;
in
{
  programs.helix.languages = with pkgs; {
    language-server = {
      pyright = {
        command = "${nodePackages.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
        config = { };
      };
      efm-python = {
        command = "${efm-langserver}/bin/efm-langserver";
        config = {
          documentFormatting = true;
          languages.python = with python3Packages; [
            {
              formatCommand = "${black}/bin/black --quiet -";
              formatStdin = true;
            }
            {
              formatCommand = "${isort}/bin/isort --quiet -";
              formatStdin = true;
            }
            {
              lintCommand = "${pylama}/bin/pylama --from-stdin \${INPUT}";
              lintStdin = true;
              lintFormats = [ "%f:%l:%c %m" ];
            }
          ];
        };
      };
      typescript-language-server = with nodePackages; {
        command = "${typescript-language-server}/bin/typescript-language-server";
        args = [ "--stdio" ];
        config.tsserver.path = "${typescript}/bin/tsserver";
      };
      eslint = {
        command = "${vscodeLSP}/bin/vscode-eslint-language-server";
        args = [ "--stdio" ];
        config = {
          format = false;
          packageManages = "npm";
          nodePath = "";
          workingDirectory.mode = "auto";
          onIgnoredFiles = "off";
          run = "onType";
          validate = "on";
          useESLintClass = false;
          experimental = { };
          codeAction = {
            disableRuleComment = {
              enable = true;
              location = "separateLine";
            };
            showDocumentation.enable = true;
          };
        };
      };
      efm-prettier = {
        command = "${efm-langserver}/bin/efm-langserver";
        config = {
          documentFormatting = true;
          languages.javascript = with nodePackages; [
            {
              formatCommand = "${prettier}/bin/prettier --stdin-filepath \${INPUT}";
              formatStdin = true;
            }
          ];
        };
      };
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
      volar = with nodePackages; {
        command = "${volar}/bin/vue-language-server";
        args = [ "--stdio" ];
        config.typescript.tsdk = "${typescript}/lib/node_modules/typescript/lib";
      };
      taplo = {
        command = "${taplo-cli}/bin/taplo";
        args = [ "lsp" "stdio" ];
      };
    };
    language = [
      {
        name = "python";
        file-types = [ "py" ];
        scope = "source.python";
        roots = [ "pyproject.toml" ];
        comment-token = "#";
        language-servers = [ "pyright" "efm-python" ];
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
        language-servers = [
          "efm-prettier"
          { name = "typescript-language-server"; except-features = [ "format" ]; }
          { name = "eslint"; except-features = [ "format" ]; }
        ];
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

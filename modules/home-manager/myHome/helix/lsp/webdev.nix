{ pkgs, ... }:

let
  vscodeLSP = pkgs.nodePackages.vscode-langservers-extracted;
in
{
  programs.helix.languages = with pkgs; {
    language-server = {
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
      html-ls = {
        command = "${vscodeLSP}/bin/vscode-html-language-server";
        args = [ "--stdio" ];
        config.provideFormatter = false;
      };
      css-ls = {
        command = "${vscodeLSP}/bin/vscode-css-language-server";
        args = [ "--stdio" ];
        config.provideFormatter = false;
      };
      nil = {
        command = "${nil}/bin/nil";
        config = {
          nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
          nil.formatting.command = [ "${nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
      };
      volar = with nodePackages; {
        command = "${volar}/bin/vue-language-server";
        args = [ "--stdio" ];
        config.typescript.tsdk = "${typescript}/lib/node_modules/typescript/lib";
      };
    };
    language = [
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
        name = "html";
        scope = "text.html.basic";
        injection-regex = "html";
        file-types = [ "html" ];
        roots = [ ];
        language-servers = [ "html-ls" "efm-prettier" ];
        auto-format = true;
        indent = { tab-width = 2; unit = "  "; };
      }
      {
        name = "css";
        scope = "source.css";
        injection-regex = "css";
        file-types = [ "css" "scss" ];
        roots = [ ];
        language-servers = [ "css-ls" "efm-prettier" ];
        auto-format = true;
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
    ];
  };
}

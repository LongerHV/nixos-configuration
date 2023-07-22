{ pkgs, ... }:

{
  myHome.helix.extraPackages = with pkgs.nodePackages; [
    typescript-language-server
    vscode-langservers-extracted
    volar
  ];

  programs.helix.languages = with pkgs; {
    language-server = {
      typescript-language-server = with nodePackages; {
        command = "typescript-language-server";
        args = [ "--stdio" ];
        config.tsserver.path = "${typescript}/bin/tsserver";
      };
      eslint = {
        command = "vscode-eslint-language-server";
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
        command = "vscode-html-language-server";
        args = [ "--stdio" ];
        config.provideFormatter = false;
      };
      css-ls = {
        command = "vscode-css-language-server";
        args = [ "--stdio" ];
        config.provideFormatter = false;
      };
      volar = with nodePackages; {
        command = "vue-language-server";
        args = [ "--stdio" ];
        config.typescript.tsdk = "${typescript}/lib/node_modules/typescript/lib";
      };
    };

    language = [
      {
        name = "javascript";
        auto-format = false;
        language-servers = [
          "efm-prettier"
          { name = "typescript-language-server"; except-features = [ "format" ]; }
          { name = "eslint"; except-features = [ "format" ]; }
        ];

      }
      {
        name = "html";
        language-servers = [ "html-ls" "efm-prettier" ];
      }
      {
        name = "css";
        language-servers = [ "css-ls" "efm-prettier" ];
      }
      {
        name = "vue";
        roots = [ "package.json" "vue.config.js" ];
        language-servers = [ "volar" ];
      }
    ];
  };
}

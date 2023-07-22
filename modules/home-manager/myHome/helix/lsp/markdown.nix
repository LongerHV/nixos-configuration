{ pkgs, ... }:

{
  myHome.helix.extraPackages = with pkgs; [ marksman nodePackages.markdownlint-cli ];
  programs.helix.languages = {
    language-server = {
      efm-markdown = {
        command = "efm-langserver";
        config = {
          documentFormatting = false;
          languages.markdown = [
            {
              lintCommand = "markdownlint --stdin";
              lintStdin = true;
              lintFormats = [ "%f:%l %m" "%f:%l:%c %m" "%f: %l: %m" ];
            }
          ];
        };
      };
    };
    language = [
      {
        name = "markdown";
        language-servers = [ "marksman" "efm-markdown" "efm-prettier" ];
      }
    ];
  };
}

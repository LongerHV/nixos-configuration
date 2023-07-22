{ pkgs, ... }:

{
  programs.helix.languages = with pkgs; {
    language-server = {
      marksman = {
        command = "${marksman}/bin/marksman";
        args = [ "server" ];
      };
      efm-markdown = {
        command = "${efm-langserver}/bin/efm-langserver";
        config = {
          documentFormatting = false;
          languages.markdown = with nodePackages; [
            {
              lintCommand = "${markdownlint-cli}/bin/markdownlint --stdin";
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
        scope = "source.md";
        injection-regex = "md|markdown";
        file-types = [ "md" "markdown" "PULLREQ_EDITMSG" ];
        roots = [ ".marksman.toml" ];
        language-servers = [ "marksman" "efm-markdown" "efm-prettier" ];
        indent = { tab-width = 2; unit = "  "; };
      }
      {
        name = "markdown.inline";
        scope = "source.markdown.inline";
        injection-regex = "markdown\\.inline";
        file-types = [ ];
        roots = [ ];
        grammar = "markdown_inline";
      }
    ];
  };
}

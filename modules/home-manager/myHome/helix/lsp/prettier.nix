{ pkgs, ... }:

{
  programs.helix.languages.language-server.efm-prettier = with pkgs; {
    command = "${efm-langserver}/bin/efm-langserver";
    config = {
      documentFormatting = true;
      languages."=" = with nodePackages; [
        {
          formatCommand = "${prettier}/bin/prettier --stdin-filepath \${INPUT}";
          formatStdin = true;
        }
      ];
    };
  };
}

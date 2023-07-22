{ pkgs, ... }:

{
  imports = [
    ./python.nix
    ./webdev.nix
    ./markdown.nix
  ];

  myHome.helix.extraPackages = with pkgs; [
    nil
    gopls
    efm-langserver
    taplo
  ] ++ (with nodePackages; [
    bash-language-server
    prettier
  ]);

  programs.helix.languages = with pkgs; {
    language-server = {
      nil.config = {
        nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
        nil.formatting.command = [ "${nixpkgs-fmt}/bin/nixpkgs-fmt" ];
      };
      efm-prettier = {
        command = "efm-langserver";
        config = {
          documentFormatting = true;
          languages."=" = [
            {
              formatCommand = "prettier --stdin-filepath \${INPUT}";
              formatStdin = true;
            }
          ];
        };
      };
    };
  };
}

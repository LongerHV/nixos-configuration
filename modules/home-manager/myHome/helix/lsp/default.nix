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
    clang-tools
    terraform-ls
  ] ++ (with nodePackages; [
    bash-language-server
    prettier
    yaml-language-server
    dockerfile-language-server-nodejs
  ]);

  programs.helix.languages = with pkgs; {
    language-server = {
      nil.config = {
        nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
        nil.formatting.command = [ "${nixpkgs-fmt}/bin/nixpkgs-fmt" ];
      };
      yaml-language-server.config.yaml.keyOrdering = false;
      vscode-json-language-server.config.provideFormatter = false;
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

    language = [
      {
        name = "json";
        language-servers = [ "efm-prettier" "vscode-json-language-server" ];
      }
    ];
  };
}

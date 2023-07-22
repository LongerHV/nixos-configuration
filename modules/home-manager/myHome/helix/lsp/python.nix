{ pkgs, ... }:

{
  myHome.helix.extraPackages = with pkgs; [
    # Use pyright version from unstable channel running on node from stable channel
    (nodePackages.pyright.override {
      inherit (unstable.nodePackages.pyright) src version name;
    })
  ] ++ (with python3Packages; [
    black
    isort
    pylama
  ]);

  programs.helix.languages = {
    language-server = {
      pyright = {
        command = "pyright-langserver";
        args = [ "--stdio" ];
        config = { };
      };
      efm-python = {
        command = "efm-langserver";
        config = {
          documentFormatting = true;
          languages.python = [
            {
              formatCommand = "black --quiet -";
              formatStdin = true;
            }
            {
              formatCommand = "isort --quiet -";
              formatStdin = true;
            }
            {
              lintCommand = "pylama --from-stdin \${INPUT}";
              lintStdin = true;
              lintFormats = [ "%f:%l:%c %m" ];
            }
          ];
        };
      };
    };

    language = [{
      name = "python";
      language-servers = [ "pyright" "efm-python" ];
    }];
  };
}

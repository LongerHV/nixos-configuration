{ pkgs, ... }:

let
  # Use pyright version from unstable channel running on node from stable channel
  pyright-unstable = pkgs.nodePackages.pyright.override {
    inherit (pkgs.unstable.nodePackages.pyright) src version name;
  };
in
{
  programs.helix.languages = {
    language-server = {
      pyright = {
        command = "${pyright-unstable}/bin/pyright-langserver";
        args = [ "--stdio" ];
        config = { };
      };
      efm-python = with pkgs; {
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
    ];
  };
}

{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        line-number = "relative";
        cursorline = true;
        indent-guides.render = true;
      };
    };
    languages = {
      language = [
        {
          name = "python";
          file-types = ["py"];
          config = {};
          roots = ["pyproject.toml"];
          language-server = {
            command = "${pkgs.nodePackages.pyright}/bin/pyright-langserver";
            args = [ "--stdio" ];
          };
        }
      ];
    };
  };
}

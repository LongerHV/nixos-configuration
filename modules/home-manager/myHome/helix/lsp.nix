{ pkgs, ... }:

{
  programs.helix.languages.language = [
    {
      name = "python";
      file-types = ["py"];
      scope = "source.python";
      roots = ["pyproject.toml"];
      comment-token = "#";
      language-server = {
        command = "${pkgs.nodePackages.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
      };
      config = {};
      indent = { tab-width = 4; unit = "    ";};
    }
    {
      name = "nix";
      scope = "source.nix";
      injection-regex = "nix";
      file-types = ["nix"];
      shebangs = [];
      roots = [];
      comment-token = "#";
      language-server.command = "${pkgs.nil}/bin/nil";
      config.nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
      indent = { tab-width = 2; unit = "  ";};
    }
  ];
}
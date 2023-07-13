{ pkgs, ... }:

{
  programs.helix.languages.language = [
    {
      name = "python";
      file-types = [ "py" ];
      scope = "source.python";
      roots = [ "pyproject.toml" ];
      comment-token = "#";
      language-server = {
        command = "${pkgs.nodePackages.pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
      };
      config = { };
      indent = { tab-width = 4; unit = "    "; };
    }
    {
      name = "go";
      scope = "source.go";
      injection-regex = "go";
      file-types = [ "go" ];
      roots = [ "go.work" "go.mod" ];
      auto-format = true;
      comment-token = "//";
      language-server.command = "${pkgs.gopls}/bin/gopls";
      indent = { tab-width = 4; unit = "\t"; };
    }
    {
      name = "nix";
      scope = "source.nix";
      injection-regex = "nix";
      file-types = [ "nix" ];
      shebangs = [ ];
      roots = [ ];
      comment-token = "#";
      indent = { tab-width = 2; unit = "  "; };
      language-server.command = "${pkgs.nil}/bin/nil";
      config.nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
      config.nil.formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
      auto-format = true;
    }
    {
      name = "bash";
      scope = "source.bash";
      injection-regex = "(shell|bash|zsh|sh)";
      file-types = [ "sh" "bash" "zsh" ".bash_login" ".bash_logout" ".bash_profile" ".bashrc" ".profile" ".zshenv" ".zlogin" ".zlogout" ".zprofile" ".zshrc" "APKBUILD" "PKGBUILD" "eclass" "ebuild" "bazelrc" ".bash_aliases" ];
      shebangs = [ "sh" "bash" "dash" "zsh" ];
      roots = [ ];
      comment-token = "#";
      language-server = { command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server"; args = [ "start" ]; };
      indent = { tab-width = 2; unit = "  "; };
    }
    {
      name = "vue";
      scope = "source.vue";
      injection-regex = "vue";
      file-types = [ "vue" ];
      roots = [ "package.json" "vue.config.js" ];
      indent = { tab-width = 2; unit = "  "; };
      language-server = {
        command = "${pkgs.nodePackages.volar}/bin/vue-language-server";
        args = [ "--stdio" ];
      };
      config.typescript.tsdk = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";
    }
  ];
}

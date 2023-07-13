{ pkgs, ... }:

{
  programs.helix.languages.language = with pkgs; [
    (with nodePackages; {
      name = "python";
      file-types = [ "py" ];
      scope = "source.python";
      roots = [ "pyproject.toml" ];
      comment-token = "#";
      language-server = {
        command = "${pyright}/bin/pyright-langserver";
        args = [ "--stdio" ];
      };
      config = { };
      indent = { tab-width = 4; unit = "    "; };
    })
    {
      name = "go";
      scope = "source.go";
      injection-regex = "go";
      file-types = [ "go" ];
      roots = [ "go.work" "go.mod" ];
      auto-format = true;
      comment-token = "//";
      language-server.command = "${gopls}/bin/gopls";
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
      language-server.command = "${nil}/bin/nil";
      config.nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
      config.nil.formatting.command = [ "${nixpkgs-fmt}/bin/nixpkgs-fmt" ];
      auto-format = true;
    }
    (with nodePackages; {
      name = "bash";
      scope = "source.bash";
      injection-regex = "(shell|bash|zsh|sh)";
      file-types = [ "sh" "bash" "zsh" ".bash_login" ".bash_logout" ".bash_profile" ".bashrc" ".profile" ".zshenv" ".zlogin" ".zlogout" ".zprofile" ".zshrc" "APKBUILD" "PKGBUILD" "eclass" "ebuild" "bazelrc" ".bash_aliases" ];
      shebangs = [ "sh" "bash" "dash" "zsh" ];
      roots = [ ];
      comment-token = "#";
      language-server = {
        command = "${bash-language-server}/bin/bash-language-server";
        args = [ "start" ];
      };
      indent = { tab-width = 2; unit = "  "; };
    })
    (with nodePackages; {
      name = "javascript";
      scope = "source.js";
      injection-regex = "(js|javascript)";
      file-types = [ "js" "mjs" "cjs" ];
      shebangs = [ "node" ];
      roots = [ ];
      comment-token = "//";
      language-server = {
        command = "${typescript-language-server}/bin/typescript-language-server";
        args = [ "--stdio" ];
        language-id = "javascript";
      };
      config.tsserver.path = "${pkgs.nodePackages.typescript}/bin/tsserver";
      indent = { tab-width = 2; unit = "  "; };

    })
    (with nodePackages;
    {
      name = "vue";
      scope = "source.vue";
      injection-regex = "vue";
      file-types = [ "vue" ];
      roots = [ "package.json" "vue.config.js" ];
      indent = { tab-width = 2; unit = "  "; };
      language-server = {
        command = "${volar}/bin/vue-language-server";
        args = [ "--stdio" ];
      };
      config.typescript.tsdk = "${typescript}/lib/node_modules/typescript/lib";
    })
  ];
}

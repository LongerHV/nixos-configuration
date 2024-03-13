{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.neovim;
  pluginOptions = _: with lib; {
    options = {
      plugin = mkOption {
        type = types.package;
      };
      main = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      opts = mkOption {
        type = types.nullOr types.attrs;
        default = null;
      };
      configFile = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
      preConfig = mkOption {
        type = types.nullOr types.lines;
        default = null;
      };
      postConfig = mkOption {
        type = types.nullOr types.lines;
        default = null;
      };
      dependencies = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [ ];
      };
    };
  };
  mkPlugin = p:
    let
      inherit (lib.strings) concatStrings;
      optional = cond: element: if cond then element else null;
      main = if p.main != null then p.main else p.plugin.pname;
      setupCommand = optional (p.opts != null) /* lua */ ''
        require("${main}").setup(vim.fn.json_decode([[${builtins.toJSON p.opts}]]))
      '';
      doConfigFileCommand = optional (p.configFile != null) /* lua */ ''
        dofile("${p.configFile}")
      '';
      config = concatStrings (builtins.filter (x: x != null) [
        p.preConfig
        setupCommand
        doConfigFileCommand
        p.postConfig
      ]);
    in
    {
      inherit (p) plugin;
      type = "lua";
      config = optional (config != "") (concatStrings [
        "-- Plugin ${p.plugin.pname}\n"
        config
        "-- end\n"
      ]);
    };
in
{
  imports = [ ./plugins ];
  options.myHome.neovim = with lib; {
    enable = mkEnableOption "neovim";
    enableLSP = mkEnableOption "enableLSP";
    plugins = mkOption {
      type = types.listOf (types.submodule pluginOptions);
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "${config.home.profileDirectory}/bin/nvim";
    };
    programs.neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = false;
      extraLuaConfig = /* lua */ ''
        dofile("${./init.lua}")
        dofile("${./theme.lua}")
        dofile("${./keymaps.lua}")
      '' + "\n";
      plugins = (builtins.map mkPlugin cfg.plugins)
        ++ (builtins.foldl' (acc: p: acc ++ p.dependencies) [ ] cfg.plugins);
      extraPackages = with pkgs; [
        nodePackages.npm
        nodePackages.neovim
      ] ++ (builtins.foldl' (acc: p: acc ++ p.extraPackages) [ ] cfg.plugins);
    };
  };
}

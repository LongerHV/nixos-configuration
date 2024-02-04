{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.neovim;
  pluginOptions = _: with lib; {
    options = {
      plugin = mkOption {
        type = types.package;
      };
      name = mkOption {
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
        type = types.lines;
        default = "";
      };
      postConfig = mkOption {
        type = types.lines;
        default = "";
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
      opt = lib.strings.optionalString;
      name = if p.name != null then p.name else p.plugin.pname;
      setupCommand = opt (p.opts != null) ''
        require("${name}").setup(vim.fn.json_decode("${lib.strings.escape ["\""] (builtins.toJSON p.opts)}"))
      '';
      configFileCommand = opt (p.configFile != null) ''
        dofile("${p.configFile}")
      '';
    in
    {
      inherit (p) plugin;
      type = "lua";
      config = /* lua */ ''
        ${p.preConfig}
        ${setupCommand}
        ${configFileCommand}
        ${p.postConfig}
      '';
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
      '';
      plugins = (builtins.map mkPlugin cfg.plugins)
        ++ (builtins.foldl' (acc: p: acc ++ p.dependencies) [ ] cfg.plugins);
      extraPackages = with pkgs; [
        nodePackages.npm
        nodePackages.neovim
      ] ++ (builtins.foldl' (acc: p: acc ++ p.extraPackages) [ ] cfg.plugins);
    };
  };
}

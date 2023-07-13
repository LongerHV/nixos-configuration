{
  imports = [ ./lsp.nix ];
  programs.helix = {
    enable = true;
    settings = {
      theme = "kanagawa";
      editor = {
        line-number = "relative";
        cursorline = true;
        indent-guides.render = true;
        rulers = [80];
      };
    };
  };
}

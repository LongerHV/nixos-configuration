{
  imports = [ ./lsp.nix ];
  programs.helix = {
    enable = true;
    settings = {
      theme = "nightfox";
      editor = {
        line-number = "relative";
        cursorline = true;
        indent-guides.render = true;
        rulers = [ 80 ];
        cursor-shape.insert = "bar";
      };
    };
  };
}

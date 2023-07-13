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
      keys.normal = {
        space.F = ":format";
        Z.Z = ":wq";
        G = "goto_last_line";
        "^" = "goto_first_nonwhitespace";
        "0" = "goto_line_start";
        "$" = "goto_line_end";
      };
    };
  };
}

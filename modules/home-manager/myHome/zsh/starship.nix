{ config, lib, ... }:
{
  config = lib.mkIf config.myHome.zsh.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$nix_shell"
          "$python"
          "$golang"
          "$kubernetes"
          "$line_break"
          "$character"
        ];
        kubernetes.format = "[$symbol$context]($style)";
      };
    };
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myHome.tmux;
in
{
  options.myHome.tmux = with lib; {
    enable = mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      terminal = "tmux-256color";
      keyMode = "vi";
      escapeTime = 10;
      newSession = true;
      plugins = with pkgs; [
        tmuxPlugins.yank
        {
          plugin = tmuxPlugins.power-theme;
          extraConfig = ''
            set-hook -g client-session-changed 'run-shell "if [ \"#{session_name}\" = \"prod\" ]; then tmux set -g @tmux_power_theme \"redwine\"; else tmux set -g @tmux_power_theme \"#99C794\"; fi; tmux run-shell ${tmuxPlugins.power-theme}/share/tmux-plugins/power/tmux-power.tmux"'
          '';
        }
      ];
      extraConfig = ''
        # TERM override
        set terminal-overrides "xterm*:RGB"

        # Enable mouse
        set -g mouse on

        # Pane movement shortcuts (same as vim)
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Copy mode using 'Esc'
        unbind [
        bind Escape copy-mode

        # Start selection with 'v' and copy using 'y'
        bind-key -T copy-mode-vi v send-keys -X begin-selection

        # Custom
        bind-key -r i neww -n goose -S -c "#{pane_current_path}" bash -c "goose session --name cli-helper"
      '';
    };
  };
}

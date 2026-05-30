{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    prefix = "`";

    terminal = "screen-256color";
    aggressiveResize = true;

    keyMode = "vi";
    customPaneNavigationAndResize = true;
    historyLimit = 10000;

    clock24 = true;

    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      { plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -ag status-right "| #[fg=#{@thm_blue}]%H:%M:%S#[default] "
          set -g @kirelagin_window_text "#{?#{==:#{pane_current_command},sudo},#[push-default]#[fg=#{@thm_red}]#T#[fg=default]#[pop-default],#T}"
          set -g @catppuccin_window_text " #{E:@kirelagin_window_text}"
          set -g @catppuccin_window_current_text " #{E:@kirelagin_window_text}"
        '';
      }
    ];

    extraConfig = ''
      set -g destroy-unattached off

      set -g activity-action any
      set -g bell-action any


      bind Space next-window
      bind BSpace previous-window

      bind | split-window -h
      bind _ split-window -v

      bind C-s setw synchronize-panes\; display-message "synchronize-panes is #{?pane_synchronized,on,off}"

      bind . command-prompt -p "Window number:" "swap-window -t '%%'"

      setw -g mouse on
    '';
  };
}

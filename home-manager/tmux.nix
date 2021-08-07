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

    extraConfig = ''
      set -g destroy-unattached off

      set -g status-style "bg=colour12,fg=black"
      set -g status-left ""
      set -g status-right "| #[fg=green,bright]%H:%M:%S#[default] "
      set -g status-right-style "bg=black,fg=white"
      setw -g window-status-format " #I #W "
      setw -g window-status-bell-style "bg=red,fg=colour12"
      setw -g window-status-current-style "bg=black,bright"
      setw -g window-status-current-format " #I #W "

      set -g status-interval 1

      set -g pane-border-style "fg=colour103"
      set -g pane-active-border-style "fg=colour12"

      set -g set-titles on
      set -g set-titles-string "#W -- #H"

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

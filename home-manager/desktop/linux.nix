{ config, lib, pkgs, ... }:

let
  cfg = config.desktop;

in {
  options.desktop = {
    enable = lib.mkEnableOption "desktop" // { default = pkgs.stdenv.isLinux; };
    xorg = lib.mkEnableOption "Xorg support" // { default = pkgs.stdenv.isLinux; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chromium
      dconf-editor
      (firefox.override { nativeMessagingHosts = [ browserpass passff-host ]; })
      gimp
      gnvim
      inkscape
      libreoffice-fresh
      pavucontrol
      quassel
      tdesktop  # Telegram
      vlc
      wl-clipboard
      xclip
    ];

    home.shellAliases = {
      open = "${lib.getBin pkgs.xdg-utils}/bin/xdg-open";
    } // lib.optionalAttrs cfg.xorg {
      pbcopy  = "${lib.getBin pkgs.xclip}/bin/xclip -selection clipboard -i";
      pbpaste = "${lib.getBin pkgs.xclip}/bin/xclip -selection clipboard -o";
    };

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        xkb-options = [
          "misc:typo" "lv3:ralt_switch"  # typo layout
          "altwin:swap_alt_win"  # swap alt and win
        ];
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "close,minimize:appmeny";

        audible-bell = false;
        visual-bell = true;
        visual-bell-type = "frame-flash";  # flash window
      };

      "org/gnome/settings-daemon/plugins/power" = {
        idle-brightness = 100;  # disable screen dimming hack
      };
    };
  };
}

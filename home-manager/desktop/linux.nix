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
      (firefox.override { extraNativeMessagingHosts = [ passff-host ]; })
      gnome3.dconf-editor
      gimp
      gnvim
      inkscape
      pavucontrol
      quassel
      tdesktop  # Telegram
      vlc
    ];

    home.shellAliases = {
      open = "${lib.getBin pkgs.xdg-utils}/bin/xdg-open";
    } // lib.optionalAttrs cfg.xorg {
      pbcopy  = "${lib.getBin pkgs.xclip}/bin/xclip -selection clipboard -i";
      pbpaste = "${lib.getBin pkgs.xclip}/bin/xclip -selection clipboard -o";
    };
  };
}

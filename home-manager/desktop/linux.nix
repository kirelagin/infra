{ config, flakes, lib, pkgs, ... }:

let
  cfg = config.desktop;

  # Unbreak by pulling legacy webkitgtk_4_0 from pinned Nixpkgs 25.05
  citrix_workspace_hack = (pkgs.citrix_workspace.overrideAttrs (origAttrs: rec {
    buildInputs = origAttrs.buildInputs ++ [
      flakes.nixpkgs-legacy.legacyPackages.x86_64-linux.webkitgtk_4_0
    ];
    # This new binary wants libfuse3.so.3, but we only have .4
    # (this is completely braindead, but I have no better ideas)
    postInstall = (origAttrs.postInstall or "") + ''
      rm -- "$out"/opt/citrix-icaclient/ctxfuse
    '';
    meta.broken = false;
  })).override {
    version = "25.08.0.88";
    hash = "sha256-eauQf8KIZlibGvDvgmouwL9cHGZRzRYpN5Ugho483aY=";
  };

in {
  options.desktop = {
    enable = lib.mkEnableOption "desktop" // { default = pkgs.stdenv.isLinux; };
    xorg = lib.mkEnableOption "Xorg support" // { default = pkgs.stdenv.isLinux; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      chromium
      citrix_workspace_hack
      darktable
      dconf-editor
      (firefox.override { nativeMessagingHosts = [ browserpass passff-host ]; })
      gimp
      gnvim
      inkscape
      libreoffice-fresh
      pavucontrol
      quassel
      rymdport
      telegram-desktop
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

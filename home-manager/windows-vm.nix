# Quick to setup Window VM

{ lib, pkgs, config, ... }:

let
  cfg = config.kir.windowsVm;
  windows-vm = pkgs.writeShellApplication {
    name = "windows-vm";
    runtimeInputs = with pkgs; [ coreutils findutils gnugrep libvirt qemu virt-manager virt-viewer zenity ];
    text = builtins.replaceStrings
      [ "readonly USB_CONTROLLER=''" ]
      [ "readonly USB_CONTROLLER=${builtins.toJSON (if cfg.usbControllerPassthrough == null then "" else cfg.usbControllerPassthrough)}" ]
      (builtins.readFile ./windows-vm/windows-vm.sh);
  };
  windows-desktop = pkgs.writeShellApplication {
    name = "windows-desktop";
    runtimeInputs = [ windows-vm pkgs.zenity ];
    text = ''
      error_file="$(${pkgs.coreutils}/bin/mktemp)"
      trap '${pkgs.coreutils}/bin/rm -f -- "$error_file"' EXIT
      if ! windows-vm start 2>"$error_file"; then
        ${pkgs.zenity}/bin/zenity --error --title="Windows" \
          --text="$(${pkgs.coreutils}/bin/cat "$error_file")"
        exit 1
      fi
    '';
  };
in {
  options.kir.windowsVm = {
    enable = lib.mkEnableOption "personal Windows VM launcher";
    usbControllerPassthrough = lib.mkOption {
      type = lib.types.nullOr (lib.types.strMatching "^[[:xdigit:]]{4}:[[:xdigit:]]{2}:[[:xdigit:]]{2}\\.[0-7]$");
      default = null;
      description = ''
        PCI BDF of a whole USB controller to pass through while preparing a new
        Windows VM, for example "0000:c3:00.3". This is not a USB device bus or
        port address. Null disables passthrough. This option does not change an
        existing domain; change its hardware manually in virt-manager.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ windows-vm pkgs.virt-manager pkgs.virt-viewer ];
    xdg.desktopEntries.windows = {
      name = "Windows";
      comment = "Start and open the personal Windows VM";
      exec = "${windows-desktop}/bin/windows-desktop";
      terminal = false;
      categories = [ "System" "Utility" ];
    };
  };
}

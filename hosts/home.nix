# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, flakes, ... }:

{
  config = {

    boot.loader.grub.enable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.grub.devices = [ "nodev" ];
    boot.loader.grub.timeoutStyle = "hidden";

    # This is a bit hacky, and hardcodes the name of this specific board.
    # TODO: Is there a better way to do this?
    boot.loader.grub.extraInstallCommands = let
      board = "amlogic/meson-gxl-s905x-libretech-cc-v2.dtb";
    in ''
      dtb_target="${config.boot.loader.efi.efiSysMountPoint}"/dtb
      dtb_target_tmp="$dtb_target".tmp.''$''$
      dtb_target_tmp_dir=$("${pkgs.coreutils}"/bin/dirname -- "$dtb_target_tmp"/"${board}")
      "${pkgs.coreutils}"/bin/rm -rf -- "$dtb_target_tmp"
      "${pkgs.coreutils}"/bin/mkdir -p -- "$dtb_target_tmp_dir"
      "${pkgs.coreutils}"/bin/cp -a -- "${config.hardware.deviceTree.kernelPackage}"/dtbs/${board} "$dtb_target_tmp_dir"/
      "${pkgs.coreutils}"/bin/rm -rf -- "$dtb_target"
      "${pkgs.coreutils}"/bin/mv -- "$dtb_target_tmp" "$dtb_target"
    '';

    boot.loader.timeout = 0;
    boot.consoleLogLevel = 7;
    boot.kernelParams = ["console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/c8b0b7fd-23de-4769-9451-3e11ad50fe03";
      fsType = "btrfs";
      options = [ "subvol=@root" "compress=zstd" "noatime" ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/C8A2-F164";
      fsType = "vfat";
      options = [ "noatime" ];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/c8b0b7fd-23de-4769-9451-3e11ad50fe03";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
    };

    fileSystems."/mnt/data" = {
      device = "/dev/disk/by-uuid/c8b0b7fd-23de-4769-9451-3e11ad50fe03";
      fsType = "btrfs";
      options = [ "subvol=@data" "compress=zstd" "noatime" ];
    };

    systemd.tmpfiles.rules = [
      "w /sys/class/leds/blue:status/trigger - - - - none"
      "w /sys/class/leds/blue:status/brightness - - - - 0"

      "w /sys/class/leds/green:disk-activity/trigger - - - - none"
      "w /sys/class/leds/green:disk-activity/brightness - - - - 0"
    ];


    ##

    networking.hostName = "home";

    system.stateVersion = "23.05";

    time.timeZone = "Europe/Zurich";

    networking.useDHCP = true;
    networking.useNetworkd = true;
    services.resolved.dnssec = "false";  # FIXME: why does it not work without??

    services.fstrim.enable = true;

    powerManagement.cpuFreqGovernor = "ondemand";
    services.dbus.implementation = "broker";

    services.nginx = {
      enable = true;
      virtualHosts."home.local".default = true;
    };

    networking.firewall.allowedTCPPorts = [
      80 443
    ];

    environment.systemPackages = with pkgs; [
      git-annex
    ];

  };
}

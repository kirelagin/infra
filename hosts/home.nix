# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, flakes, ... }:

{
  config = {

    ##
    # Snatched this from `installer/sd-card` because otherwise it does a lot of useless stuff

    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    boot.consoleLogLevel = 7;
    boot.kernelParams = ["console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/c8b0b7fd-23de-4769-9451-3e11ad50fe03";
      fsType = "btrfs";
      options = [ "subvol=@root" "compress=zstd" "noatime" ];
    };

    # I don't know how to move the u-boot stuff to eMMC, so sdcard is still
    # necesary for booting
    fileSystems."/run/mount/sdcard" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    systemd.tmpfiles.rules = [
      "L /boot - - - - /run/mount/sdcard/boot"
    ];

    fileSystems."/mnt/data" = {
      device = "/dev/disk/by-uuid/c8b0b7fd-23de-4769-9451-3e11ad50fe03";
      fsType = "btrfs";
      options = [ "subvol=@data" "compress=zstd" "noatime" ];
    };


    ##

    networking.hostName = "home";

    system.stateVersion = "23.05";

    time.timeZone = "America/New_York";

    networking.useDHCP = true;
    networking.useNetworkd = true;

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

  };
}

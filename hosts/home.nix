# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, flakes, ... }:

{
  imports = [
    "${flakes.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  config = {

    ##
    # Snatched this from `installer/sd-card` because otherwise it does a lot of useless stuff

    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    boot.consoleLogLevel = 7;
    boot.kernelParams = ["console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"];

    # Not sure if this firmware thing is even actally needed...
    sdImage = {
      populateFirmwareCommands = let
        configTxt = pkgs.writeText "config.txt" ''
          [all]
          # Boot in 64-bit mode.
          arm_64bit=1

          # U-Boot needs this to work, regardless of whether UART is actually used or not.
          # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
          # a requirement in the future.
          enable_uart=1

          # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
          # when attempting to show low-voltage or overtemperature warnings.
          avoid_warnings=1
        '';
        in ''
          # Add the config
          cp ${configTxt} firmware/config.txt
        '';
      populateRootCommands = ''
        mkdir -p ./files/boot
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
      '';

      postBuildCommands =
        let
          buildPkgs = flakes.nixpkgs.legacyPackages.x86_64-linux;
          uboot = buildPkgs.pkgsCross.aarch64-multiplatform.ubootLibreTechCC;
        in ''
          dd if="${uboot}/u-boot.gxl.sd.bin" of="$img" conv=fsync,notrunc bs=1 count=444
          dd if="${uboot}/u-boot.gxl.sd.bin" of="$img" conv=fsync,notrunc bs=512 skip=1 seek=1
        '';
    };

    ##

    networking.hostName = "home";

    system.stateVersion = "23.05";

    time.timeZone = "America/New_York";

    networking.useDHCP = true;
    networking.useNetworkd = true;

    services.fstrim.enable = true;

    services.nginx = {
      enable = true;
      virtualHosts."home.local".default = true;
    };

    networking.firewall.allowedTCPPorts = [
      80 443
    ];

  };
}

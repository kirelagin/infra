# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, lib, pkgs, ... }:

let
  linuxPackages = pkgs.linuxPackages_latest;


in {
  imports = [
    flakes.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  config = {
    # Bleeding-edge
    boot.kernelPackages = linuxPackages;

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ linuxPackages.framework-laptop-kmod ];

    boot.kernelParams = [
      #"pm_debug_messages" "amd_pmc.dyndbg"
    ];

    boot.kernelPatches = lib.optionals (lib.versionOlder linuxPackages.kernel.version "6.10") [
      { name = "fw-amd-ec"; patch = ../patches/kernel/fw-amd-ec.patch; }
    ] ++ lib.optionals (lib.versionOlder linuxPackages.kernel.version "6.7.8") [
      { name = "amdgpu-drm-buddy-alloc_range"; patch = ../patches/kernel/amdgpu-drm-buddy-alloc_range.patch; }
    ];

    services.udev.extraRules = ''
      # Allow wheel to set the battery charge capacity
      SUBSYSTEM=="power_supply", RUN+="${pkgs.coreutils}/bin/chgrp -f wheel /sys%p/charge_control_end_threshold"
      SUBSYSTEM=="power_supply", RUN+="${pkgs.coreutils}/bin/chmod -f  0660 /sys%p/charge_control_end_threshold"
    '';

    boot.initrd.luks.devices."root" = {
      device = "/dev/disk/by-uuid/44a90e36-0327-4d09-b4b3-88fd9d258af9";
      crypttabExtraOpts = [ "tpm2-device=auto" "fido2-device=auto" ];
      allowDiscards = true;
    };

    boot.initrd.systemd = {
      storePaths = [ "${pkgs.fw-ectool}/bin/ectool" ];

      services.remap-keys = {
        description = "Swap left Win and Alt on the Framework keyboard";
        wantedBy = [ "initrd.target" ];

        #from typing import List, Tuple
        #
        #def ec_keymap(write: bool, items: List[Tuple[int, int, int]]):
        #    print(','.join(
        #      [ f'd{len(items):x},d{int(write):x}' ] +
        #      ['b{:x},b{:x},w{:x}'.format(*item) for item in items]
        #    ))
        #
        ## LAlt = (1, 3, 0x11)
        ## LWin = (3, 1, 0xe01f)
        #ec_keymap(True, [(1,3,0xe01f), (3,1,0x11)])
        script = ''
          "${pkgs.fw-ectool}"/bin/ectool raw 0x3E0C d2,d1,b1,b3,we01f,b3,b1,w11
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/6b25f0fe-70c3-4c41-9398-41182be07f80";
        fsType = "btrfs";
        options = [ "subvol=@root" "compress=zstd" "noatime" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/EADD-2F3E";
        fsType = "vfat";
        options = [ "noatime" "umask=007" "nofail" ];
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/6b25f0fe-70c3-4c41-9398-41182be07f80";
        fsType = "btrfs";
        options = [ "subvol=@home" "compress=zstd" "noatime" ];
      };

    fileSystems."/nix" =
      { device = "/dev/disk/by-uuid/6b25f0fe-70c3-4c41-9398-41182be07f80";
        fsType = "btrfs";
        options = [ "subvol=@nix" "compress=zstd" "noatime" ];
      };

    fileSystems."/run/swap" =
      { device = "/dev/disk/by-uuid/6b25f0fe-70c3-4c41-9398-41182be07f80";
        fsType = "btrfs";
        options = [ "subvol=@swap" "noatime" "nofail" ];
      };

    swapDevices = [
      { device = "/run/swap/swapfile";
      }
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.firmware = [ pkgs.linux-firmware ];  # amdgpu and mediatek

    security.tpm2.enable = true;

    networking.hostName = "kirFw";

    environment.systemPackages = [ pkgs.fw-ectool ];

    system.stateVersion = "23.05";
  };
}

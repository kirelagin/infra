# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, lib, pkgs, ... }:

{
  imports = [
    flakes.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  config = {
    # Bleeding-edge
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    boot.kernelParams = [ "amdgpu.sg_display=0" ];

    boot.initrd.luks.devices."root" = {
      device = "/dev/disk/by-uuid/44a90e36-0327-4d09-b4b3-88fd9d258af9";
      crypttabExtraOpts = [ "tpm2-device=auto" "fido2-device=auto" ];
      allowDiscards = true;
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

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.firmware = [ pkgs.linux-firmware ];  # amdgpu and mediatek

    security.tpm2.enable = true;

    networking.hostName = "kirFw";

    system.stateVersion = "23.05";
  };
}

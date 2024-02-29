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
    boot.extraModulePackages = [ (pkgs.linuxPackages_latest.callPackage ../pkgs/framework-laptop-kmod { }) ];

    boot.kernelParams = [
      "amdgpu.sg_display=0"
      "rtc_cmos.use_acpi_alarm=1"
      "pm_debug_messages" "amd_pmc.dyndbg"  # FIXME
    ];

    boot.kernelPatches = [
      { name = "fw-amd-ec"; patch = ../patches/kernel/fw-amd-ec.patch; }
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

    hardware.framework.amd-7040.preventWakeOnAC = true;

    # XXX: use HEAD for Mario's fixes
    services.power-profiles-daemon.package = pkgs.power-profiles-daemon.overrideAttrs (old: {
      src = flakes.power-profiles-daemon;
      version = flakes.power-profiles-daemon.lastModifiedDate;

      nativeBuildInputs = (lib.filter (d: !(lib.hasPrefix "python" d.name)) old.nativeBuildInputs) ++ [
        (pkgs.python3.pythonOnBuildForHost.withPackages (ps: with ps; [
          pygobject3
          dbus-python
          python-dbusmock
          pylint
          argparse-manpage
          shtab
        ]))
        pkgs.cmake
      ];
      buildInputs = old.buildInputs ++ [
        pkgs.bash-completion
      ];
    });

    # XXX: amdgpu firmware fixup
    nixpkgs.overlays = [
      (final: prev: {
        linux-firmware = let
          vcn_bin = final.fetchurl {
            url = "https://gitlab.freedesktop.org/mesa/mesa/uploads/f51d221a24d4ac354e2d1d901613b594/vcn_4_0_2.bin";
            hash = "sha256-6I849LwnGg6YviNy+IYT751WMHavW2bK0MbuqE3V5GU=";
          };
        in prev.linux-firmware.overrideAttrs (old: {
          outputHash = null;
          postInstall = (old.postInstall or "") + ''
            cp "${vcn_bin}" "$out"/lib/firmware/amdgpu/vcn_4_0_2.bin
          '';
        });
      })
    ];

    security.tpm2.enable = true;

    networking.hostName = "kirFw";

    system.stateVersion = "23.05";
  };
}

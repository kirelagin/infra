{ pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Bleeding-edge
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/bb50f319-8ac5-431a-aab7-c9a9f8dced77";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/a0cca707-3cae-4575-9673-d25e59f97268";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DBB1-334C";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/bdd86810-fc8a-4bf2-9300-8c3207a6f05c";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };

  fileSystems."/nix/store" =
    { device = "/dev/disk/by-uuid/59f3b3e8-c529-4bd6-af28-d45c6d14f712";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7a2b1564-47b6-48c5-b201-0eace9a1ee8a"; }
    ];

  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];

  hardware.video.hidpi.enable = true;

  networking.hostName = "kirXps";

  # TODO: should be set automatically
  time.timeZone = "America/New_York";

  system.stateVersion = "20.09";
}
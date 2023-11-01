{ pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Bleeding-edge
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.systemd.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "mem_sleep_default=deep" ];  # defaults to fake suspend??

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
    { device = "/dev/disk/by-uuid/0dfc813e-43e8-475e-9dfd-e818ff0758fb";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" "subvol=home" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/0dfc813e-43e8-475e-9dfd-e818ff0758fb";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" "subvol=nix" "compress=zstd" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7a2b1564-47b6-48c5-b201-0eace9a1ee8a"; }
    ];

  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];

  # Grayscale anti-aliasing
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.subpixel = {
    rgba = "none";
    lcdfilter = "none";
  };

  #qt = {
  #  enable = true;
  #  style = lib.mkForce "adwaita-dark";
  #};

  boot.initrd.systemd = {
    storePaths = [ "${pkgs.kbd}/bin/setkeycodes" ];

    services.remap-keys = {
      description = "Remap left Win and Alt";
      wantedBy = [ "initrd.target" ];

      script = ''
        ${pkgs.kbd}/bin/setkeycodes 38 125
        ${pkgs.kbd}/bin/setkeycodes db 56
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };

  networking.hostName = "kirXps";

  services.throttled.enable = true;

  security.tpm2 = {
    enable = true;
    abrmd.enable = true;
    pkcs11.enable = true;
  };

  # Gala (from Pantheon) spams logs. Dirty fix: at least do not write this bs to disk.
  services.journald.extraConfig = ''
    Storage=volatile
  '';

  services.tlp.settings = {
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MAX_PERF_ON_BAT = 100;
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  };

  system.stateVersion = "23.05";


  services.xserver.displayManager.sessionCommands = ''
    export $(/run/current-system/systemd/bin/systemctl --user show-environment | grep -v ' ' | grep -v 'XDG_\(DATA\|CONFIG\)_DIRS' | grep -v 'PATH=')
    export "$(/run/current-system/systemd/bin/systemctl --user show-environment | grep '^PATH='):$PATH"
  '';

  nix.settings = {
    substituters = [
      #"https://hydra.iohk.io"
    ];

    trusted-public-keys = [
      #"hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip gutenprint ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

}

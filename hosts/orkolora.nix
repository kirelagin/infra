{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/746ddff1-574b-4d18-9491-5b868925d47d";
      fsType = "ext4";
    };
  };

  services.qemuGuest.enable = true;

  colour.css = "#ffcc00";

  networking = {
    hostName = "orkolora";
    domain = "kir.elagin.me";

    useDHCP = false;

    interfaces.ens18 = {
      ipv4.addresses = [
        { address = "109.230.195.99"; prefixLength = 26; }
      ];
      ipv6.addresses = [
        { address = "2605:6400:30:fa9e:0000::ff90:4000"; prefixLength = 48; }
        { address = "2a02:d40:3:13:109:230:195:99"; prefixLength = 64; }
      ];
    };

    defaultGateway = "109.230.195.65";
    defaultGateway6 = {
      address = "2a02:d40:3:13::1";
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="2e:58:e3:c5:4e:89", NAME="ens18"
  '';


  nix.settings.max-jobs = 1;

  system.stateVersion = "23.11";
}

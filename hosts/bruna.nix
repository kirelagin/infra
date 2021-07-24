{ pkgs, lib, ... }:

{
  boot.loader.grub = {
    enable = true;
    version = 2;
  };
  boot.loader.grub.device = "/dev/vda";

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fe761ffe-ed1d-46c0-b7fc-7c75e004880b";
      fsType = "ext4";
    };

  swapDevices = [
    { device = "/dev/disk/by-uuid/cb76b10f-d2eb-402c-aa11-d35f2edacfee"; }
  ];

  networking = {
    hostName = "bruna";
    domain = "kir.elagin.me";

    interfaces.ens3 = {
      ipv4.addresses = [
        { address = "104.244.79.71"; prefixLength = 24; }
      ];
      ipv6.addresses = [
        { address = "2605:6400:30:fa9e:0000::ff90:4000"; prefixLength = 48; }
      ];
    };

    defaultGateway = "104.244.79.1";
    defaultGateway6 = {
      address = "2605:6400:30::1";
      metric = 256;
    };
  };

  networking.firewall.allowedTCPPorts = [ 11234 ];  # for testing

  nix.maxJobs = 1;

  system.stateVersion = "18.03";
}

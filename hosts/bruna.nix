{ pkgs, lib, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/fe761ffe-ed1d-46c0-b7fc-7c75e004880b";
      fsType = "ext4";
    };
    "/mnt" = {
      device = "/dev/disk/by-uuid/581d2578-7695-4569-92b7-8557d7606417";
      fsType = "btrfs";
      options = [ "nofail" ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/cb76b10f-d2eb-402c-aa11-d35f2edacfee"; }
  ];

  colour.css = "#904000";

  networking = {
    hostName = "bruna";
    domain = "kir.elagin.me";

    useDHCP = false;

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

  nix.settings.max-jobs = 1;

  system.stateVersion = "23.05";
}

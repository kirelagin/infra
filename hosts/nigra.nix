{ pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  boot.initrd.availableKernelModules = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0905329d-4022-4692-bb5d-b614c117dd8c";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2bab0d29-6c12-4665-83d4-f986119f946f";
      fsType = "ext4";
    };

  services.qemuGuest.enable = true;

  colour.css = "#000000";

  networking = {
    hostName = "nigra";
    domain = "kir.elagin.me";

    useDHCP = false;

    interfaces.ens3 = {
      ipv4.addresses = [
        { address = "85.198.64.6"; prefixLength = 32; }
      ];
      ipv4.routes = [
        { address = "100.100.1.1"; prefixLength = 32; via = "0.0.0.0"; }
      ];
    };

    defaultGateway = {
      address = "100.100.1.1";
      interface = "ens3";
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="00:72:0d:42:76:b5", NAME="ens3"
  '';


  nix.settings.max-jobs = 1;

  system.stateVersion = "25.11";
}

# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
    dns = {
      url = "github:kirelagin/nix-dns/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, dns, mailserver }: {

    nixosConfigurations = {
      bruna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	specialArgs = { flakes = inputs; };
        modules =
          [ ({ pkgs, ... }: {
              boot.initrd.availableKernelModules =
                [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

              boot.loader.grub.device = "/dev/vda";

              fileSystems."/" =
                { device = "/dev/disk/by-uuid/fe761ffe-ed1d-46c0-b7fc-7c75e004880b";
                  fsType = "ext4";
                };

              swapDevices = [
                { device = "/dev/disk/by-uuid/cb76b10f-d2eb-402c-aa11-d35f2edacfee"; }
              ];

              nix.maxJobs = nixpkgs.lib.mkDefault 1;

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
            })
          ] ++ (with self.nixosModules.services; [
            mail
            nginx
            nsd
          ]) ++ (with self.nixosModules.apps; [
            nginx-static
            nginx-stub
            dns-kirelagin-me
            vpn
            legacy-tunnel
          ]) ++ (with self.nixosModules.config; [
            boot-loader
            defaults
          ]);
      };
    };

    nixosModules = {
      services = {
        mail = import ./modules/services/mailserver.nix;
        nginx = import ./modules/services/nginx.nix;
        nsd = import ./modules/services/nsd.nix;
      };

      apps = {
        dns-kirelagin-me = import ./modules/apps/dns/elagin.me.nix;
        legacy-tunnel = import ./modules/apps/vpn/legacy-tunnel.nix;
        nginx-static = import ./modules/apps/web/static.nix;
        nginx-stub = import ./modules/apps/web/stub.nix;
        vpn = import ./modules/apps/vpn/vpn.nix;
      };

      config = {
        boot-loader = import ./modules/config/grub.nix;
        defaults = import ./modules/config/defaults.nix;
      };
    };

  };
}

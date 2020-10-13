# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    dns = {
      url = "github:kirelagin/nix-dns";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-20.09";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, dns, mailserver }: {

    nixosConfigurations = {
      bruna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/bruna.nix)
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
            defaults
          ]);
      };

      kirXps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/kirXps.nix)
          ] ++ (with self.nixosModules.config; [
            defaults
            laptop
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
        defaults = import ./modules/config/defaults.nix;
        laptop = import ./modules/config/laptop.nix;
      };
    };

  };
}

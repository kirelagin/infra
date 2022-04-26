# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-u.url = "github:NixOS/nixpkgs/nixos-unstable";
    dns = {
      url = "github:kirelagin/nix-dns";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-21.11";
      flake = false;
    };
    prompt_kir = {
      url = "github:kirelagin/prompt_kir";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-u, dns, mailserver, prompt_kir, home-manager }: {

    nixosConfigurations = {
      bruna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/bruna.nix)
          ] ++ (with self.nixosModules.services; [
            backups
            mail
            nginx
            nsd
          ]) ++ (with self.nixosModules.apps; [
            nginx-static
            nginx-stub
            dns-kirelagin-me
            vpn
            legacy-tunnel
            storage
          ]) ++ (with self.nixosModules.config; [
            defaults
          ]);
      };

      kirXps = nixpkgs-u.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/kirXps.nix)
            { flakes.nixpkgs = nixpkgs-u; }
          ] ++ (with self.nixosModules.config; [
            defaults
            laptop
          ]);
      };

      infosec = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules = [{
          boot.isContainer = true;
        }] ++ (with self.nixosModules.config; [
          defaults
          infosec
        ]);
      };
    };

    nixosModules = {
      services = {
        backups = import ./modules/services/backups.nix;
        mail = import ./modules/services/mailserver.nix;
        nginx = import ./modules/services/nginx.nix;
        nsd = import ./modules/services/nsd.nix;
      };

      apps = {
        dns-kirelagin-me = import ./modules/apps/dns/elagin.me.nix;
        legacy-tunnel = import ./modules/apps/vpn/legacy-tunnel.nix;
        nginx-static = import ./modules/apps/web/static.nix;
        nginx-stub = import ./modules/apps/web/stub.nix;
        storage = import ./modules/apps/storage.nix;
        vpn = import ./modules/apps/vpn/vpn.nix;
      };

      config = {
        defaults = import ./modules/config/defaults.nix;
        infosec = import ./modules/config/infosec.nix;
        laptop = import ./modules/config/laptop.nix;
        secrets = import ./modules/config/secrets.nix;
      };
    };

  };
}

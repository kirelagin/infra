# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-u.url = "github:NixOS/nixpkgs/nixos-unstable";
    dns = {
      url = "github:kirelagin/nix-dns";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      flake = false;
    };
    prompt_kir = {
      url = "github:kirelagin/prompt_kir";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-u, ... }: {

    packages = {
      x86_64-linux = {
        # This one is not really x86_64... it is a mix:
        # the bootloader is cross-compiled from x86_64 to target,
        # but the OS itself is built through qemu...
        home-sdcard-img = self.nixosConfigurations.home.config.system.build.sdImage;
      };
    };

    nixosConfigurations = {
      bruna = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/bruna.nix)
          ] ++ (with self.nixosModules.services; [
            backups
            mail
            nextcloud
            nginx
            nsd
            postgresql
          ]) ++ (with self.nixosModules.apps; [
            nginx-static
            nginx-stub
            dns-kirelagin-me
            vpn
            legacy-tunnel
            storage
            tesla-fleet
          ]) ++ (with self.nixosModules.config; [
            defaults
            headless
          ]);
      };

      orkolora = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/orkolora.nix)
          ] ++ (with self.nixosModules.services; [
            nginx
          ]) ++ (with self.nixosModules.apps; [
            nginx-stub
          ]) ++ (with self.nixosModules.config; [
            defaults
            headless
          ]);
      };

      kirXps = nixpkgs-u.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/kirXps.nix)
            { flakes.nixpkgs = nixpkgs-u; }
          ] ++ (with self.nixosModules.services; [
            steam
          ]) ++ (with self.nixosModules.config; [
            defaults
            laptop
          ]);
      };

      kirFw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { flakes = inputs; };
        modules =
          [ (import ./hosts/kirFw.nix)
            { flakes.nixpkgs = nixpkgs; }
          ] ++ (with self.nixosModules.services; [
            steam
          ]) ++ (with self.nixosModules.config; [
            defaults
            laptop
            secure-boot
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

      home = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { flakes = inputs; };
        modules = [
          ./hosts/home.nix
          {
            #nixpkgs.config.allowUnsupportedSystem = true;
          }
        ] ++ (with self.nixosModules.services; [
          home-assistant
        ]) ++ (with self.nixosModules.config; [
          defaults
          headless
          home-device
        ]);
      };
    };

    nixosModules = {
      services = {
        backups = import ./modules/services/backups.nix;
        home-assistant = import ./modules/services/home-assistant.nix;
        mail = import ./modules/services/mailserver.nix;
        nextcloud = import ./modules/services/nextcloud.nix;
        nginx = import ./modules/services/nginx.nix;
        nsd = import ./modules/services/nsd.nix;
        postgresql = import ./modules/services/postgresql.nix;
        steam = import ./modules/services/steam.nix;
      };

      apps = {
        dns-kirelagin-me = import ./modules/apps/dns/elagin.me.nix;
        legacy-tunnel = import ./modules/apps/vpn/legacy-tunnel.nix;
        nginx-static = import ./modules/apps/web/static.nix;
        nginx-stub = import ./modules/apps/web/stub.nix;
        storage = import ./modules/apps/storage.nix;
        tesla-fleet = import ./modules/apps/tesla-fleet.nix;
        vpn = import ./modules/apps/vpn/vpn.nix;
      };

      config = {
        defaults = import ./modules/config/defaults.nix;
        headless = import ./modules/config/headless.nix;
        home-device = import ./modules/config/home-device.nix;
        infosec = import ./modules/config/infosec.nix;
        laptop = import ./modules/config/laptop.nix;
        secrets = import ./modules/config/secrets.nix;
        secure-boot = import ./modules/config/secure-boot.nix;
      };
    };

  };
}

# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, lib, flakes, ... }:

{
  imports = [
    flakes.lanzaboote.nixosModules.lanzaboote
  ];

  config = {
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    environment.systemPackages = [ pkgs.sbctl ];
  };
}

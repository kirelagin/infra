# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, lib, flakes, ... }:

{
  config = {
    #services.fwupd.enable = true;

    services.avahi = {
      enable = true;
      ipv6 = true;
      nssmdns = true;
      publish = {
        # wtf, realy??
        enable = true;
        userServices = true;
        addresses = true;
      };
      extraServiceFiles = {
        ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
      };
    };

  };
}

# SPDX-FileCopyrightText: 2024 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:

{
  config = {
    assertions = [
      { assertion = config ? backups;
        message = "The backups module must be included";
      }
    ];

    services.postgresql.enable = true;

    backups.streams.postgresql = {
      filename = "postgresql-dumpall.sql";
      command = "${pkgs.writeShellScript "postgresql-dumpall" ''
        exec /run/wrappers/bin/sudo -u postgres "${config.services.postgresql.package}/bin/pg_dumpall"
      ''}";
    };
  };
}

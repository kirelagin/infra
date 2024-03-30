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

    # Backups
    systemd.services.postgres-restic-backup = {
      restartIfChanged = false;
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = lib.filter (d: d.name == "restic-backup") config.environment.systemPackages;  # HACK
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "postgres-restic-backup" ''
          /run/wrappers/bin/sudo -u postgres "${config.services.postgresql.package}/bin/pg_dumpall" | restic-backup backup --tag postgresql --stdin
        '';
        User = "root";
        RuntimeDirectory = "postgres-restic-backup";
        CacheDirectory = "postgres-restic-backup";
        PrivateTmp = true;
      };
    };
    systemd.timers.postgres-restic-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = config.services.restic.backups.backup.timerConfig;
    };
  };
}

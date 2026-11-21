# SPDX-FileCopyrightText: 2022 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.backups;

  secretConfig = {
    owner = config.services.restic.backups.backup.user;
    group = "root";
  };
in

{
  options.backups = {
    repository = mkOption {
      type = types.str;
      default = "b2:backup-${config.networking.hostName}";
      description = "Restic repository";
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Paths to backup.";
    };

    streams = mkOption {
      default = {};
      description = "Named commands whose stdout is backed up to the shared Restic repository.";
      type = types.attrsOf (types.submodule {
        options = {
          command = mkOption {
            type = types.str;
            description = "Executable that writes a complete backup to stdout and fails on export errors.";
          };
          filename = mkOption {
            type = types.strMatching "[A-Za-z0-9][A-Za-z0-9._-]*";
            description = "Filename of the streamed file in the Restic snapshot.";
          };
        };
      });
    };

    credsSecretName = mkOption {
      type = types.str;
      default = "backups/${config.networking.hostName}/b2-creds";
      description = "Name of the secret with b2 credentials.";
    };

    encryptionSecretName = mkOption {
      type = types.str;
      default = "backups/${config.networking.hostName}/password";
      description = "Name of the secret with the encryption key.";
    };

    commandsBefore = mkOption {
      type = types.lines;
      default = "";
      description = "Commands to run before starting the backup";
    };

    commandsAfter = mkOption {
      type = types.lines;
      default = "";
      description = "Commands to run after finishing the backup";
    };
  };

  config = {
    secrets.secrets = {
      "${cfg.credsSecretName}" = secretConfig;
      "${cfg.encryptionSecretName}" = secretConfig;
    };

    assertions = lib.mapAttrsToList (name: _: {
      assertion = builtins.match "[a-z0-9]+(-[a-z0-9]+)*" name != null;
      message = "backups.streams.${name}: name must contain only lowercase letters, digits, and internal hyphens";
    }) cfg.streams;

    services.restic.backups = {
      backup = {
        passwordFile = config.secrets.secrets."${cfg.encryptionSecretName}".path;
        environmentFile = config.secrets.secrets."${cfg.credsSecretName}".path;
        initialize = true;

        inherit (cfg) repository paths;
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
          "--group-by tags"
        ];

        backupPrepareCommand = cfg.commandsBefore;
        backupCleanupCommand = cfg.commandsAfter;
      };
    } // lib.mapAttrs' (name: stream: lib.nameValuePair "stream-${name}" {
      inherit (cfg) repository;
      inherit (config.services.restic.backups.backup) passwordFile environmentFile package user;
      command = [ stream.command ];
      extraBackupArgs = [ "--tag" name "--stdin-filename" stream.filename ];
      timerConfig = null;
      pruneOpts = [];
    }) cfg.streams;

    systemd = lib.mkIf (cfg.streams != {} && config.services.restic.backups.backup.timerConfig != null) {
      timers.restic-backups-backup.timerConfig.Unit = "restic-backups-run.service";
      services.restic-backups-run = {
        description = "Run file and streamed Restic backups";
        serviceConfig.Type = "oneshot";
        script = ''
          failed=0
          ${pkgs.systemd}/bin/systemctl start restic-backups-backup.service || failed=1
          for unit in ${lib.concatMapStringsSep " " (name: lib.escapeShellArg "restic-backups-stream-${name}.service") (lib.attrNames cfg.streams)}; do
            ${pkgs.systemd}/bin/systemctl start "$unit" || failed=1
          done
          exit "$failed"
        '';
      };
    };
  };
}


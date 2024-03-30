# SPDX-FileCopyrightText: 2022 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:

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

    services.restic.backups.backup = {
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
  };
}


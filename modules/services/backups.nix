# SPDX-FileCopyrightText: 2022 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  cfg = config.backups;

  secretConfig = {
    owner = "${config.services.restic.backups.backup.user}:root";
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
      default = "backup-${config.networking.hostName}-creds";
      description = "Name of the secret with b2 credentials.";
    };

    encryptionSecretName = mkOption {
      type = types.str;
      default = "backup-${config.networking.hostName}";
      description = "Name of the secret with the encryption key.";
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
      ];
    };
  };
}


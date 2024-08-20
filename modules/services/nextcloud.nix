# SPDX-FileCopyrightText: 2024 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:

{
  config = {
    assertions = [
      { assertion = config.services.postgresql.enable;
        message = "services.postgresql.enable must be true";
      }
    ];

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      hostName = "cloud.s.kir.elagin.me";
      https = true;

      home = "/mnt/data/nextcloud";
      config.adminpassFile = config.secrets.secrets.nextcloud-admin.path;
      config.dbtype = "pgsql";
      database.createLocally = true;
      configureRedis = true;
      phpOptions."opcache.interned_strings_buffer" = "16";

      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
          calendar
          contacts
          deck
          memories
          notes
          phonetrack
          previewgenerator
          tasks
          twofactor_webauthn
        ;
      };

      settings = {
        overwriteprotocol = "https";

        # Run heavy meaintenance jobs at this time (hour) in UTC.
        maintenance_window_start = 7;

        # Send mail locally
        mail_smtpmode = "sendmail";
        mail_sendmailmode = "pipe";

        # Enable HEIC previews
        enabledPreviewProviders = [
          # Text
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\TXT"
          "OC\\Preview\\OpenDocument"

          # Audio
          "OC\\Preview\\MP3"

          # Images
          "OC\\Preview\\Krita"
          "OC\\Preview\\Imaginary"
        ];

        # Fix paths used by apps
        "preview_ffmpeg_path" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.exiftool_no_local" = "true";
        "memories.exiftool" = "${lib.getExe pkgs.exiftool}";
        "memories.vod.ffmpeg" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";

        "preview_imaginary_url" = "http://${config.services.imaginary.address}:${toString config.services.imaginary.port}";
      };
      enableImagemagick = false;  # Use imaginary instead
    };
    services.imaginary.enable = true;
    services.imaginary.settings.return-size = true;  # had to set to true, the NixOS module is broken :/

    # HACK: for memories
    systemd.services.nextcloud-cron = {
      path = [pkgs.perl];
    };

    secrets.secrets.nextcloud-admin = {
      owner = "nextcloud";
      group = "nextcloud";
    };

    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
    };

    backups = {
      commandsBefore = ''${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --on'';
      commandsAfter = ''${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --off'';
    };
  };
}

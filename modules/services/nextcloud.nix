# SPDX-FileCopyrightText: 2024 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, pkgs, ... }:

let
  oidcBaseUrl = "https://${config.services.nextcloud.hostName}/apps/user_oidc";
in
{
  config = {
    assertions = [
      { assertion = config.services.postgresql.enable;
        message = "services.postgresql.enable must be true";
      }
    ];

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud34;
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
          user_oidc
        ;
      };

      settings = {
        overwriteprotocol = "https";
        user_oidc = {
          auto_provision = false;
          enable_default_claims = false;
        };

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
        ];

        # Fix paths used by apps
        "preview_ffmpeg_path" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.exiftool_no_local" = "true";
        "memories.exiftool" = "${lib.getExe pkgs.exiftool}";
        "memories.vod.ffmpeg" = "${lib.getExe pkgs.ffmpeg-headless}";
        "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
      };
      enableImagemagick = true;
    };

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = "nextcloud";
        client_name = "Nextcloud";
        authorization_policy = "owner_only";
        public = false;
        token_endpoint_auth_method = "private_key_jwt";
        token_endpoint_auth_signing_alg = "ES384";
        # Authelia defaults each of these to client_secret_basic independently.
        revocation_endpoint_auth_method = "private_key_jwt";
        revocation_endpoint_auth_signing_alg = "ES384";
        introspection_endpoint_auth_method = "private_key_jwt";
        introspection_endpoint_auth_signing_alg = "ES384";
        pushed_authorization_request_endpoint_auth_method = "private_key_jwt";
        pushed_authorization_request_endpoint_auth_signing_alg = "ES384";
        require_pkce = true;
        pkce_challenge_method = "S256";
        # The stock nginx front controller omits /index.php from generated URLs.
        redirect_uris = [ "${oidcBaseUrl}/code" ];
        jwks_uri = "${oidcBaseUrl}/jwks";
        grant_types = [ "authorization_code" ];
        response_types = [ "code" ];
        scopes = [ "openid" "profile" "email" ];
      }
    ];

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

# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
# SPDX-License-Identifier: MPL-2.0
{
  config,
  lib,
  pkgs,
  ...
}:
let
  names = [
    "authelia-storage"
    "authelia-users"
  ];
  secret = name: config.secrets.secrets.${name}.path;
  backendPort = 9091;
  domain = config.networking.domain;
  hostname = "auth.s.${domain}";
in
{
  secrets.secrets = lib.genAttrs names (_: {
    owner = "authelia-main";
    group = "authelia-main";
  });

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      # The upstream NixOS assertion assumes reset-password JWTs are always
      # used; manual mode bypasses that assertion, NOT Authelia validation.
      manual = true;
      storageEncryptionKeyFile = secret "authelia-storage";
    };
    settings = {
      server.address = "tcp://127.0.0.1:${toString backendPort}/";
      authentication_backend = {
        file.path = secret "authelia-users";
        password_reset.disable = true;
      };
      webauthn = {
        enable_passkey_login = true;
        # NOTE: Upstream explicitly marks this switch experimental.
        experimental_enable_passkey_uv_two_factors = true;
        selection_criteria = {
          attachment = "cross-platform";
          discoverability = "required";
          user_verification = "required";
        };
      };
      access_control = {
        default_policy = "deny";
        # Authelia requires a rule for a deny-by-default access policy.
        # Future OIDC clients will need their own independent owner policy.
        rules = [
          {
            domain = hostname;
            subject = "user:kirelagin";
            policy = "two_factor";
          }
        ];
      };
      session.cookies = [
        {
          domain = "s.${domain}";
          authelia_url = "https://${hostname}";
        }
      ];
      storage.local.path = "/var/lib/authelia-main/db.sqlite3";
      notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";
      # TODO: add OIDC when we have clients

    };
  };

  backups.streams.authelia-db = {
    command = "${pkgs.writeShellScript "authelia-sqlite-snapshot" ''
      set -euo pipefail
      umask 077
      database=${lib.escapeShellArg config.services.authelia.instances.main.settings.storage.local.path}
      test -s "$database" || { echo 'Authelia database is missing or empty' >&2; exit 1; }
      scratch=$(${pkgs.coreutils}/bin/mktemp -d "''${RUNTIME_DIRECTORY:?}/snapshot.XXXXXXXX")
      trap '${pkgs.coreutils}/bin/rm -rf -- "$scratch"' EXIT
      snapshot="$scratch/db.sqlite3"
      ${pkgs.sqlite}/bin/sqlite3 -batch -readonly -cmd '.timeout 30000' "$database" \
        ".backup '$snapshot'" >/dev/null
      test -s "$snapshot" || { echo 'Authelia SQLite snapshot is empty' >&2; exit 1; }
      result=$(${pkgs.sqlite}/bin/sqlite3 -batch -readonly "$snapshot" 'PRAGMA quick_check;')
      test "$result" = ok || { echo 'Authelia SQLite snapshot failed quick_check' >&2; exit 1; }
      ${pkgs.coreutils}/bin/cat -- "$snapshot"
    ''}";
    filename = "authelia-main.sqlite3";
  };

  services.nginx = {
    enable = true;
    virtualHosts.${hostname} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString backendPort}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-Host $host;
        '';
      };
    };
  };
}

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
  oidcKeyDirectory = "oidc-keys";
  oidcKeyPath = "/var/lib/authelia-main/${oidcKeyDirectory}";
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
      oidcIssuerPrivateKeyFile = "${oidcKeyPath}/issuer.pem";
      oidcHmacSecretFile = "${oidcKeyPath}/hmac";
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
      identity_providers.oidc = {
        authorization_policies.issuer_fallback_deny = {
          default_policy = "deny";
          # Authelia requires at least one rule with a subject or network.
          rules = [
            {
              policy = "deny";
              networks = [
                "0.0.0.0/0"
                "::/0"
              ];
            }
          ];
        };
        # Authelia requires a client. Normal client definitions replace this
        # default and merge with one another.
        clients = lib.mkDefault [
          {
            client_id = "issuer-fallback";
            authorization_policy = "issuer_fallback_deny";
            public = true;
            token_endpoint_auth_method = "none";
            require_pkce = true;
            pkce_challenge_method = "S256";
            redirect_uris = [ "https://authelia-oidc.invalid/callback" ];
            grant_types = [ "authorization_code" ];
            response_types = [ "code" ];
            scopes = [ "openid" ];
          }
        ];
      };
    };
  };

  # Run as the native service user, before the module's validate-config pre-start.
  systemd.services.authelia-main.serviceConfig.ExecStartPre = lib.mkBefore [
    (pkgs.writeShellScript "authelia-oidc-keys" ''
      set -euo pipefail
      umask 077
      cd "''${STATE_DIRECTORY:?}"
      keys=${oidcKeyDirectory}
      if [[ -e "$keys" || -L "$keys" ]]; then
        if [[ -d "$keys" && ! -L "$keys" &&
              -f "$keys/issuer.pem" && ! -L "$keys/issuer.pem" && -s "$keys/issuer.pem" &&
              -f "$keys/hmac" && ! -L "$keys/hmac" && -s "$keys/hmac" ]]; then
          exit 0
        fi
        echo 'Authelia OIDC key state is incomplete; refusing to replace it' >&2
        exit 1
      fi

      # Stage in the same filesystem and publish both files with one rename.
      scratch=$(${pkgs.coreutils}/bin/mktemp -d .oidc-keys.XXXXXXXX)
      trap '${pkgs.coreutils}/bin/rm -rf -- "$scratch"' EXIT
      ${pkgs.openssl}/bin/openssl genpkey -quiet -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$scratch/issuer.pem"
      ${pkgs.openssl}/bin/openssl rand -hex -out "$scratch/hmac" 32
      ${pkgs.coreutils}/bin/mv -T --update=none-fail -- "$scratch" "$keys"
    '')
  ];

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

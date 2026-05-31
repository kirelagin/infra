# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, ... }:

{

  imports = [
    (import flakes.mailserver)
  ];

  config = {

    mailserver = {
      enable = true;
      fqdn = "${config.networking.hostName}.${config.networking.domain}";
      domains = [ "elagin.me" "kir.elagin.me" ];

      accounts = {
        "kir@elagin.me" = {
          hashedPasswordFile = config.secrets.secrets.mailserver.path;
          aliases = [ "kirill@elagin.me" "📧@kir.elagin.me" ];
        };
      };
      aliases = {
        "abuse@elagin.me" = "kir@elagin.me";
        "postmaster@elagin.me" = "kir@elagin.me";
        "ruf@elagin.me" = "kir@elagin.me";
      };

      hierarchySeparator = "/";

      x509.useACMEHost = config.mailserver.fqdn;

      enableImap = true;
      enableImapSsl = true;

      localDnsResolver = false;

      dmarcReporting = {
        enable = true;
      };

      stateVersion = 3;
    };

    secrets.secrets.mailserver = {
      owner = "dovecot2";
      group = "dovecot2";
    };

    backups.paths = [ config.mailserver.storage.path ];

  };
}

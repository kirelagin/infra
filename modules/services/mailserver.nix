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

      loginAccounts = {
        "kir@elagin.me" = {
          hashedPasswordFile = config.secrets.secrets.mailserver.path;
          aliases = [ "kirill@elagin.me" "📧@kir.elagin.me" ];
        };
      };
      extraVirtualAliases = {
        "abuse@elagin.me" = "kir@elagin.me";
        "postmaster@elagin.me" = "kir@elagin.me";
      };

      hierarchySeparator = "/";

      certificateScheme = 3;

      enableImap = true;
      enableImapSsl = true;

      localDnsResolver = false;
    };

    secrets.secrets.mailserver = {
      owner = "dovecot2:dovecot2";
    };

    backups.paths = [ config.mailserver.mailDirectory ];

  };
}

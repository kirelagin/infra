{ config, flakes, ... }:

{
  config = {

    imports = [
      flakes.mailserver
    ];

    mailserver = {
      enable = true;
      fqdn = "${config.networking.hostName}.${config.networking.domain}";
      domains = [ "elagin.me" ];

      loginAccounts = {
        "kir@elagin.me" = {
          hashedPassword = import ../../credentials/mailserver.nix;
          aliases = [ "kirill@elagin.me" ];
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

  };
}

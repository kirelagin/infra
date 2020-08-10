# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:

{
  config = {
    assertions = [
      { assertion = config.services.nginx.enable;
        message = "services.nginx.enable must be true";
      }
    ];

    services.nginx = {
      virtualHosts = {
        "${config.networking.hostName}.${config.networking.domain}" = {
          default = true;
          forceSSL = true;
          enableACME = !config.boot.isContainer;
          locations."/" = {
            root = "/var/www";
          };
        };
      };
    };
  };
}

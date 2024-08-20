# SPDX-FileCopyrightText: 2024 Kirill Elagin <https://kir.elagin.me/>
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
        "tesla.s.kir.elagin.me" = {
          forceSSL = true;
          enableACME = !config.boot.isContainer;
          locations."/" = {
            root = "/var/lib/tesla-fleet";
          };
        };
      };
    };
  };
}

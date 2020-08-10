# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ ... }:

{
  config = {
    services.nsd = {
      enable = true;
      interfaces = [];
      verbosity = 2;
    };

    networking.firewall.allowedUDPPorts = [ 53 ];
    networking.firewall.allowedTCPPorts = [ 53 ];
  };
}

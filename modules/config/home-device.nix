# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ ... }:

{
  config = {
    #services.fwupd.enable = true;

    services.resolved = {
      settings.Resolve = {
        "MulticastDNS" = true;
      };
    };
    systemd.network.networks."99-ethernet-default-dhcp" = {
      networkConfig."MulticastDNS" = true;
    };
    networking.firewall.allowedUDPPorts = [ 5353 ];

  };
}

# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:

{
  config = {
    services.nginx = {
      enable = true;
      package = pkgs.nginxMainline;

      recommendedOptimisation = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;

      recommendedTlsSettings = true;
      sslProtocols = "TLSv1.3";
      sslCiphers = null;
      sslDhparam = true;
    };

    networking.firewall.allowedTCPPorts = [
      80 443  # TODO: collect from virtualHosts
    ];
  };
}

# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, lib, ... }:

let
  # Listen on a different port and redirect port 53 from external (non-`lo`)
  # interface to this other port.
  # So that we do not conflict with systemd-resolved listening on localhost:53.
  cfg = config.homedns;

in

{
  options.homedns = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 1053;
    };
    routerDomain = lib.mkOption {
      type = lib.types.str;
    };
    routerIp = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    services.unbound = {
      enable = true;

      resolveLocalQueries = false;

      settings = {
        server = {
          interface-automatic = true;
          interface-automatic-ports = ''${toString cfg.port}'';
          access-control = [
            "0.0.0.0/0 allow"
            "::0/0 allow"
          ];

          prefetch = true;

          domain-insecure = [ "${cfg.routerDomain}." ];
          private-domain = [ "${cfg.routerDomain}." ];

          local-data = [
            ''"home.s.kir.elagin.me. IN CNAME home.${cfg.routerDomain}."''
          ];
        };

        stub-zone = [
          {
            name = "${cfg.routerDomain}.";
            stub-addr = "${cfg.routerIp}";
            stub-no-cache = true;
          }
        ];

        forward-zone = [
          {
            name = ".";
            forward-addr = [
              "1.1.1.1@853#cloudflare-dns.com"
              "1.0.0.1@853#cloudflare-dns.com"
              "2606:4700:4700::1111@853#cloudflare-dns.com"
              "2606:4700:4700::1001@853#cloudflare-dns.com"
            ];
            forward-tls-upstream = true;
          }
        ];

        remote-control.control-enable = true;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    networking.nftables = {
      enable = true;
      tables."nixos-fw".content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;
          iifname != "lo" udp dport 53 redirect to :${toString cfg.port}
          iifname != "lo" tcp dport 53 redirect to :${toString cfg.port}
        }
      '';
    };

  };
}

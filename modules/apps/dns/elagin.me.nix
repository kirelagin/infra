# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, lib, ... }:

let
  nokey = addr: addr + " NOKEY";

  trifle = {
    xfr = [ "195.24.156.218" "2001:470:1f0b:1c94::218" ];
    notify = "195.24.156.218";
    ns = "ns2.trifle.net.";
  };
  afraid = {
    xfr = [ "69.65.50.192" "2001:1850:1:5:800::6b" ];
    notify = "69.65.50.192";
    ns = "ns2.afraid.org.";
  };
  onecom = {
    xfr = [ "46.30.211.18" "2a02:2350:5:210::1" ];
    notify = "46.30.211.18";
    ns = [ "ns01.one.com." "ns02.one.com." ];
  };
  buddyns = {
    ips = [
      "108.61.224.67" "116.203.6.3" "107.191.99.111" "193.109.120.66" "23.27.101.128"
      "192.184.93.99" "103.25.56.55" "216.73.156.203" "37.143.61.179" "195.20.17.193"
      "45.77.29.133" "116.203.0.64" "167.88.161.228" "199.195.249.208" "104.244.78.122"
      "2605:6400:30:fd6e::3" "2605:6400:10:65::3" "2605:6400:20:d5e::3" "2a01:4f8:1c0c:8122::3" "2001:19f0:7001:381::3"
      "2a10:1fc0:d::ae75:f39a" "2a01:a500:2766::5c3f:d10b" "2602:fafd:902:51::a" "2406:d500:2::de4f:f105" "2604:180:1:92a::3"
      "2606:fc40:4003:26::a" "2a10:1fc0:1::e313:41be" "2604:180:2:4cf::3" "2a01:4f8:1c0c:8115::3" "2001:19f0:6400:8642::3"
    ];
    notify = [ "2a01:4f8:1c0c:8115::3" "2604:180:2:4cf::3" "2606:fc40:4003:26::a" "2602:fafd:902:51::a" ];
    ns = [
      "uz5x36jqv06q5yulzwcblfzcrk1b479xdttdm1nrgfglzs57bmctl8.free.ns.buddyns.com."  # c (Germany)
      "uz588h0rhwuu3cc03gm9uckw0w42cqr459wn1nxrbzhym2wd81zydb.free.ns.buddyns.com."  # d (New York)
      "uz5154v9zl2nswf05td8yzgtd0jl6mvvjp98ut07ln0ydp2bqh1skn.free.ns.buddyns.com."  # f (Singapore)
      "uz5qfm8n244kn4qz8mh437w9kzvpudduwyldp5361v9n0vh8sx5ucu.free.ns.buddyns.com."  # i (California)
      # "uz53c7fwlc89h7jrbxcsnxfwjw8k6jtg56l4yvhm6p2xf496c0xl40.free.ns.buddyns.com."  # b (Texas)
      # "uz5c15kc3lkws2mtwp7l8g9f33yffvvt96y54tlmn41zjy0043purm.free.ns.buddyns.com."  # e (Estonia)
      # "uz5dkwpjfvfwb9rh1qj93mtup0gw65s6j7vqqumch0r9gzlu8qxx39.free.ns.buddyns.com."  # g (Seattle)
      # "uz5w6sb91zt99b73bznfkvtd0j1snxby06gg4hr0p8uum27n0hf6cd.free.ns.buddyns.com."  # h (Adelaide)
      # "uz56xw8h7fw656bpfv84pctjbl9rbzbqrw4rpzdhtvzyltpjdmx0zq.free.ns.buddyns.com."  # j (UK)
      # "uz5x6wcwzfbjs8fkmkuchydn9339lf7xbxdmnp038cmyjlgg9sprr2.free.ns.buddyns.com."  # k (Israel)
      # "uz52u1wtmumlrx5fwu6nmv22ntcddxcjjw41z8sfd6ur9n7797lrv9.free.ns.buddyns.com."  # l (Japan)
    ];
  };

  elagin-me-zone = with flakes.dns.lib.combinators; {
    SOA = {
      nameServer = "ns1";
      adminEmail = "kirelagin@gmail.com";
      serial = 2026010801;
    };

    NS = lib.flatten [
      "ns1.elagin.me."
      afraid.ns
      trifle.ns
      onecom.ns
      buddyns.ns
    ];

    CAA = letsEncrypt "kir@elagin.me";

    MX = [ (mx.mx 10 "bruna.kir.elagin.me.") ];

    DKIM = [
      { selector = "mail";
        p = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCiYuCjO2Hrdk5wf9j3LJ1i06ZpoTwRyWDS4ml2Xz+SmQ+h7/eurm4poxZqE2th5nb9P62fUbZV7eYGJev23y8cDABAqrEnZStmE2YWqxP6NN3AInBiMkvhAt41eM3/FJsuycnFILl8UYb6/9WYLB2EaGBabodlTOy6x9wDC19wwIDAQAB";
      }
    ];
    DMARC = [ (dmarc.postmarkapp "mailto:re+ifjzjmjecfw@dmarc.postmarkapp.com" // { p = "quarantine"; sp = "quarantine"; ruf = ["mailto:ruf@elagin.me"]; fo = [ "1" ]; }) ];

    TXT = [
      (spf.strict ["mx"])
    ] ++ [
      # Verifications
      "google-site-verification=7eSteX9R6IiaSz32CvanrfKPetdlL-QfBHAgInmDMXU"
      "google-site-verification=mMKdzA0obsuEQKadoH4361PHWnW1esoQZ657TiQtPGI"
      "firebase=kir-elagin-me"
      "globalsign-domain-verification=ItLiGzsKrucx89txkuBZAYFi67bYGGtlzVBzuQYgkh"
    ];

    subdomains = rec {
      ns1 = kir.subdomains.bruna;

      kir = {
        A = [ "151.101.1.195" "151.101.65.195" ];  # Firebase

        TXT = [
          # Verifications
          "google-site-verification=1sIBb7cmbbKl4hG_P_ZoXas1fwD1nQ2TtVy4kW-SKW4"
          "yandex-verification: 5092e0d91e8d4817"
          "keybase-site-verification=Jtjfnsjk7P1RZV7n68cdbGjcqh2hrwUuSTovvF4axO0"
        ];

        MX = [ (mx.mx 10 "bruna.kir.elagin.me.") ];

        subdomains = {
          www.CNAME = [ "kir.elagin.me." ];

          go = {
            CNAME = [ "kirelagin.gitlab.io." ];
            subdomains._gitlab-pages-verification-code = {
              TXT = [ "gitlab-pages-verification-code=546f72e34cdf7e80c95522fef5fe9854" ];
            };
          };

          blog.CNAME = [ "ghc.google.com." ];

          bruna = host "104.244.79.71" "2605:6400:30:fa9e::ff90:4000";
          blanka = host null "2a13:9f40:0:25:2aec:5ba6:84f1:aed9";
          orkolora = host "109.230.195.99" "2a02:d40:3:13:109:230:195:99";
          nigra = host "85.198.64.6" null;

          s.subdomains = {
            cloud.CNAME = [ "bruna.kir.elagin.me." ];
            tesla.CNAME = [ "bruna.kir.elagin.me." ];
            vpn.CNAME = [ "bruna.kir.elagin.me." ];
            mysticflow.CNAME = [ "blanka.kir.elagin.me." ];
          };

          _atproto.TXT = [ "did=did:plc:csdzev2ancxx2orclfy66xi2" ];  # Bluesky verification
        };
      };
    };
  };

in {
  config = {
    assertions = [
      { assertion = config.services.nsd.enable;
        message = "config.services.nsd must be enabled";
      }
    ];

    services.nsd.zones =
      {
        "elagin.me" = {
          provideXFR = map nokey (lib.flatten [ trifle.xfr afraid.xfr onecom.xfr buddyns.ips ]);
          notify = map nokey (lib.flatten [ trifle.notify afraid.notify onecom.notify buddyns.notify ]);
          data = flakes.dns.lib.toString "elagin.me" elagin-me-zone;
        };
      };
  };
}

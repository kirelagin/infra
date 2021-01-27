# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, ... }:

let
  elagin-me-zone = with flakes.dns.lib.combinators; {
    SOA = {
      nameServer = "ns1";
      adminEmail = "kirelagin@gmail.com";
      serial = 2020091400;
    };

    NS = [
      "ns1.elagin.me."
      "ns2.afraid.org."
      "ns2.trifle.net."
      "ns1.gratisdns.dk."
      "ns2.gratisdns.dk."
      #"ns3.gratisdns.dk."
      "ns4.gratisdns.dk."
      "ns5.gratisdns.dk."
    ];

    CAA = letsEncrypt "kir@elagin.me";

    MX = [ (mx.mx 10 "bruna.kir.elagin.me.") ];

    DKIM = [
      { selector = "mail";
        p = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCiYuCjO2Hrdk5wf9j3LJ1i06ZpoTwRyWDS4ml2Xz+SmQ+h7/eurm4poxZqE2th5nb9P62fUbZV7eYGJev23y8cDABAqrEnZStmE2YWqxP6NN3AInBiMkvhAt41eM3/FJsuycnFILl8UYb6/9WYLB2EaGBabodlTOy6x9wDC19wwIDAQAB";
      }
    ];
    DMARC = [ (dmarc.postmarkapp "mailto:re+ifjzjmjecfw@dmarc.postmarkapp.com") ];

    TXT = [
      (spf.strict ["mx"])
    ] ++ [
      # Verifications
      "google-site-verification=7eSteX9R6IiaSz32CvanrfKPetdlL-QfBHAgInmDMXU"
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

          s.subdomains = {
            vpn.CNAME = [ "bruna.kir.elagin.me." ];
          };
        };
      };
    };
  };

  kirelag-in-zone = with flakes.dns.lib.combinators; {
    SOA = {
      nameServer = "ns1.elagin.me.";
      adminEmail = "kirelagin@gmail.com";
      serial = 2019041102;
    };

    NS = map ns [
      "ns1.elagin.me."
      "ns2.afraid.org."
      "ns2.trifle.net."
    ];

    TXT = [
      "google-site-verification=g5HX9rRosUzT7Of3fM4bG1edzOwR4pGTG0tsKLSSP_8"
    ];

    CAA = letsEncrypt "kir@elagin.me";

    subdomains = {
      srk.CNAME = ["serokell.github.io."];
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
      let
        trifle = "195.24.128.164 NOKEY";
        trifle-notify = "195.24.156.218 NOKEY";
        afraid = "69.65.50.192 NOKEY";
        afraid-notify = "69.65.50.223 NOKEY";
        gratisdns = "91.221.196.0/28 NOKEY";
        gratisdns-notify = "91.221.196.11 NOKEY";
      in {
        "elagin.me" = {
          provideXFR = [ trifle afraid gratisdns ];
          notify = [ trifle-notify afraid-notify gratisdns-notify ];
          data = flakes.dns.lib.toString "elagin.me" elagin-me-zone;
        };
        "kirelag.in" = {
          provideXFR = [ trifle afraid ];
          notify = [ trifle-notify afraid-notify ];
          data = flakes.dns.lib.toString "kirelag.in" kirelag-in-zone;
        };
      };
  };
}

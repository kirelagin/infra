{ config, lib, pkgs, flakes, ... }:

let
  # FIXME: upstream this
  helpers = ''
    ip46tables() {
      ${pkgs.iptables}/bin/iptables -w "$@"
      ${pkgs.iptables}/bin/ip6tables -w "$@"
    }
  '';

in {
  config = {
    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "172.16.200.1/24" "2605:6400:30:fa9e:ff01::ff90:4000/72" ];
        listenPort = 16200;
        # TODO: This stores the secret key in the store :(
        privateKey = import ../../../credentials/wireguard.nix;
        peers = [
          { allowedIPs = [ "172.16.200.2"  "2605:6400:30:fa9e:ff02::0/80" ];  # minano
            publicKey = "etxITkU1t8IZy/5nW/dcUTC+i2SPwIMf+ZFfGOm7J1I=";
          }
          { allowedIPs = [ "172.16.200.3"  "2605:6400:30:fa9e:ff03::0/80" ];  # kirOne
            publicKey = "Otk1Q2CsTTsH2eDalyUhvfs+G6VZX2nQ7pbw1fOJGSo=";
          }
          { allowedIPs = [ "172.16.200.4"  "2605:6400:30:fa9e:ff04::0/80" ];  # kirMac
            publicKey = "MgkB+AFVs6qp9oOet+5F5JrMEQzpmtSaPcJWQs3gknY=";
          }
          { allowedIPs = [ "172.16.200.5"  "2605:6400:30:fa9e:ff05::0/80" ];  # lglinskih-osx
            publicKey = "VQXQAnqIOXCY1swtGTsOet08ojEEqRUO0vxC4hANFC4=";
          }
          { allowedIPs = [ "172.16.200.10" "2605:6400:30:fa9e:ff0a::0/80" ];  # dacha
            publicKey = "y3oLdyOzcGXTgG1p/aAnhLFxHNu4vkgLslE5KPmipRQ=";
          }
          { allowedIPs = [ "172.16.200.11" "2605:6400:30:fa9e:ff0b::0/80" ];  # raya
            publicKey = "pHVXT2OUY0ZvgcV97PbaP3+59OLrnndLXNnYEpar9nM=";
          }
          { allowedIPs = [ "172.16.200.12" "2605:6400:30:fa9e:ff0c::0/80" ];  # parnas
            publicKey = "onSq3fG+b//QmzO699CzeF4YBG9s+wehL7eE81++AWk=";
          }
          { allowedIPs = [ "172.16.200.13" "2605:6400:30:fa9e:ff0d::0/80" ];  # kirOne7t
            publicKey = "HRZEyv2L24UPRefRF1bJ/sFRD+ZLO5xb6y96Z7UnCF0=";
          }
        ];
        postSetup = [
          helpers
          ''${pkgs.bash}/bin/bash -c "echo 1 > /proc/sys/net/ipv4/conf/all/forwarding"''
          ''${pkgs.bash}/bin/bash -c "echo 1 > /proc/sys/net/ipv6/conf/all/forwarding"''
          ''ip46tables -w -A FORWARD -i wg0 -j ACCEPT''
          ''ip46tables -w -A FORWARD -o wg0 -j ACCEPT''
          ''ip46tables -w -t nat -A POSTROUTING -o ens3 -j MASQUERADE''
        ];
        postShutdown = [
          helpers
          ''ip46tables -w -t nat -D POSTROUTING -o ens3 -j MASQUERADE''
          ''ip46tables -w -D FORWARD -o wg0 -j ACCEPT''
          ''ip46tables -w -D FORWARD -i wg0 -j ACCEPT''
          ''${pkgs.bash}/bin/bash -c "echo 0 > /proc/sys/net/ipv6/conf/all/forwarding"''
          ''${pkgs.bash}/bin/bash -c "echo 0 > /proc/sys/net/ipv4/conf/all/forwarding"''
        ];
      };
    };

    networking.firewall.allowedUDPPorts = [
      config.networking.wireguard.interfaces.wg0.listenPort
    ];

    ### TODO: Extra wg ports
    # networking.firewall.extraCommands = ''
    #   iptables -t nat -I PREROUTING -i ens3 -d ${ipv4.address}/32 -p udp -m multiport --dports 500,3478 -j REDIRECT --to-ports ${toString ports.wg}
    # '';
    # networking.firewall.extraStopCommands = ''
    #   iptables -t nat -D PREROUTING -i ens3 -d ${ipv4.address}/32 -p udp -m multiport --dports 500,3478 -j REDIRECT --to-ports ${toString ports.wg}
    # '';
  };
}

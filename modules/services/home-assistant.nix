# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{
  config,
  lib,
  pkgs,
  ...
}:

let
  images = {
    ha = {
      imageName = "homeassistant/home-assistant";
      imageDigest = "sha256:612d76760b544cb40b7ba01387fdac964c59a6a550a50a4d30b4773c822d2918";
      sha256 = "sha256-dHdwjvN606tvv9uhlR9EYckanaXy+HlR2tg/nNiR2js=";
    };
    #zwave-js-ui = {
    #  imageName = "zwavejs/zwave-js-ui";
    #  imageDigest = "";
    #  sha256 = "";
    #};
  };
  #zwave_dev = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_stick_533D004242-if00";
  zigbee_dev = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_d017f77b9438ef119d823e7af3d9b1e5-if00-port0";
  thread_dev = "/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_26d5361072f5ef11ae059ea29ed47d52-if00-port0";

in

{
  config = {

    hardware.bluetooth.enable = true;

    users.groups.otbr = { };

    services.openthread-border-router = {
      enable = true;
      extraArgs = [ "--syslog-disable" ];
      openFirewall = false;
      backboneInterfaces = [ "end0" ];
      interfaceName = "wpan0";
      radio = {
        device = thread_dev;
        baudRate = 460800;
        flowControl = false;
      };
      rest = {
        listenAddress = "127.0.0.1";
        listenPort = 8081;
      };
      web = {
        enable = true;
        listenAddress = "127.0.0.1";
        listenPort = 8082;
      };
    };

    services.matterjs-server = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 5580;
      openFirewall = false;
      bluetoothSupport = false;
    };

    # Matter subscriptions from sleepy devices can be idle longer than the
    # kernel's default two-minute UDP stream conntrack timeout.
    boot.kernel.sysctl."net.netfilter.nf_conntrack_udp_timeout_stream" = 3600;

    networking.firewall = {
      filterForward = true;
      trustedInterfaces = [ "wpan0" ];
      extraForwardRules = ''
        # Established/related return traffic is accepted before this chain.
        # These FORWARD rules leave Thread-to-local-host INPUT traffic unchanged.
        # OTBR's ingress chain still validates advertised Thread destinations.
        ct state new iifname "end0" oifname "wpan0" accept comment "allow LAN to Thread"
        ct state new iifname "wpan0" oifname != "wpan0" reject comment "reject Thread egress"
      '';
    };

    # Staged manually until the radio and network are validated.
    systemd.services.otbr-agent = {
      wantedBy = lib.mkForce [ ];
      serviceConfig = {
        Group = "otbr";
        StateDirectoryMode = "0700";
        UMask = lib.mkForce "0007";
      };
    };

    systemd.services.otbr-web = {
      partOf = [ "otbr-agent.service" ];
      wantedBy = lib.mkForce [ ];
      serviceConfig = {
        Group = "otbr";
        # otbr-web also sends this copy to syslog, which remains in journald.
        StandardError = "null";
      };
    };

    # Staged manually until commissioning and restart tests pass.
    systemd.services.matterjs-server = {
      wantedBy = lib.mkForce [ ];
      wants = [ "otbr-agent.service" ];
      after = [ "otbr-agent.service" ];
    };

    secrets.secrets.zigbee2mqtt-network = {
      owner = "zigbee2mqtt";
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        serial = {
          port = zigbee_dev;
          adapter = "ember";
        };
        mqtt = {
          server = "mqtt://127.0.0.1:1883";
          user = "zigbee2mqtt";
          password = "zigbee2mqtt";
          base_topic = "zigbee2mqtt";
        };
        homeassistant.enabled = true;
        permit_join = false;
        frontend = {
          enabled = true;
          host = "127.0.0.1";
          port = 8080;
        };
      };
    };

    systemd.services.zigbee2mqtt = {
      wants = [ "mosquitto.service" ];
      after = [ "mosquitto.service" ];
      serviceConfig.EnvironmentFile = [ config.secrets.secrets.zigbee2mqtt-network.path ];
    };

    systemd.services."podman-homeassistant" = {
      wants = [
        "mosquitto.service"
        "zigbee2mqtt.service"
      ];
      after = [
        "mosquitto.service"
        "zigbee2mqtt.service"
      ];
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          address = "127.0.0.1";
          port = 1883;
          users = {
            homeassistant = {
              password = "homeassistant";
              acl = [
                "readwrite homeassistant/#"
                "readwrite zigbee2mqtt/#"
              ];
            };
            zigbee2mqtt = {
              password = "zigbee2mqtt";
              acl = [
                "read homeassistant/status"
                "write homeassistant/#"
                "readwrite zigbee2mqtt/#"
              ];
            };
          };
        }
      ];
    };

    virtualisation.oci-containers = {
      containers = {
        homeassistant = {
          image = images.ha.imageName;
          imageFile = pkgs.dockerTools.pullImage images.ha;
          volumes = [ "home-assistant:/config" ];
          capabilities = {
            NET_ADMIN = true;
            NET_RAW = true;
          };
          extraOptions = [
            "--network=host"
            "--volume=/run/dbus:/run/dbus:ro" # bluetooth
          ];
          #dependsOn = [ "zwave-js" ];
        };

        #zwave-js = {
        #  image = images.zwave-js-ui.imageName;
        #  imageFile = pkgs.dockerTools.pullImage images.zwave-js-ui;
        #  volumes = [ "zwave-js:/usr/src/app/store" ];
        #  extraOptions = [
        #    "--device=${zwave_dev}:/dev/zwave"
        #  ];
        #  ports = [
        #    "3000:3000/tcp"
        #    "8091:8091/tcp"
        #  ];
        #};
      };
    };

    services.nginx = {
      recommendedProxySettings = true;
      virtualHosts."home.local" = {
        forceSSL = false;
        enableACME = false;
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://[::1]:8123";
          proxyWebsockets = true;
        };
      };
    };

  };
}

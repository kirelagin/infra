# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:

let
  images = {
    ha = {
      imageName = "homeassistant/home-assistant";
      imageDigest = "sha256:f73512ba4fe06bb4d57636fe3578d0820cdec46f81e8f837ab59e451662ff3cb";
      sha256 = "sha256-39RzMAimG2Wt6a+jTBcJOkWmZvyXi3GBrt/uKm4gu/Q=";
    };
    #zwave-js-ui = {
    #  imageName = "zwavejs/zwave-js-ui";
    #  imageDigest = "";
    #  sha256 = "";
    #};
  };
  #zwave_dev = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_stick_533D004242-if00";
  zigbee_dev = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_d017f77b9438ef119d823e7af3d9b1e5-if00-port0";

in

{
  config = {

    hardware.bluetooth.enable = true;

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
            "--volume=/run/dbus:/run/dbus:ro"  # bluetooth
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

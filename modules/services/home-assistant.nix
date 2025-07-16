# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:

let
  images = {
    ha = {
      imageName = "homeassistant/home-assistant";
      imageDigest = "sha256:a8aab945aec2f43eb1b1fde4d19e25ef952fab9c10f49e40d3b3ce7d24cedc19";
      sha256 = "0wk702asy4hxbwfspdb8njd445mhh06b0vx54qw935fxbs1blsdc";
    };
    zwave-js-ui = {
      imageName = "zwavejs/zwave-js-ui";
      imageDigest = "sha256:69966e5a4bf1a6c52cb8b1c15037471a47cd07ae4fcdf24bf807019bba9ce2ee";
      sha256 = "0cp4kcnzlqa4zn0vk7dw4f2mwxvrqlbqkk8wfbc4l59686jyfw5p";
    };
  };
  ha_version = "2025.7.2";
  zwave-js-ui_version = "10.9.0";
  zwave_dev = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_stick_533D004242-if00";
  zigbee_dev = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_d017f77b9438ef119d823e7af3d9b1e5-if00-port0";

in

{
  config = {

    hardware.bluetooth.enable = true;

    virtualisation.oci-containers = {
      containers = {
        homeassistant = {
          image = images.ha.imageName;
          imageFile = pkgs.dockerTools.pullImage images.ha;
          volumes = [ "home-assistant:/config" ];
          extraOptions = [
            "--network=host"
            "--volume=/run/dbus:/run/dbus"  # bluetooth
            "--device=${zigbee_dev}:/dev/zigbee"
          ];
          dependsOn = [ "zwave-js" ];
        };

        zwave-js = {
          image = images.zwave-js-ui.imageName;
          imageFile = pkgs.dockerTools.pullImage images.zwave-js-ui;
          volumes = [ "zwave-js:/usr/src/app/store" ];
          extraOptions = [
            "--device=${zwave_dev}:/dev/zwave"
          ];
          ports = [
            "3000:3000/tcp"
            "8091:8091/tcp"
          ];
        };
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

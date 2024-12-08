# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, ... }:

let
  ha_version = "2024.12.1";
  zwave-js-ui_version = "9.27.8";
  zwave_dev = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_stick_533D004242-if00";
  zigbee_dev = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_d017f77b9438ef119d823e7af3d9b1e5-if00-port0";

in

{
  config = {

    hardware.bluetooth.enable = true;

    virtualisation.oci-containers = {
      containers = {
        homeassistant = {
          image = "ghcr.io/home-assistant/home-assistant:${ha_version}";
          volumes = [ "home-assistant:/config" ];
          extraOptions = [
            "--network=host"
            "--volume=/run/dbus:/run/dbus"  # bluetooth
            "--device=${zigbee_dev}:/dev/zigbee"
          ];
          dependsOn = [ "zwave-js" ];
        };

        zwave-js = {
          image = "zwavejs/zwave-js-ui:${zwave-js-ui_version}";
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

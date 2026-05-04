# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:

let
  images = {
    ha = {
      imageName = "homeassistant/home-assistant";
      imageDigest = "sha256:c71e7a3780d917b8217c17515263d1461ec2bff192660d7dd30cd8889519ebfe";
      sha256 = "sha256-OkkHRGMlT47kw8L+/CFxeeZa6qYl0X1EvZgcON5RMuI=";
    };
    zwave-js-ui = {
      imageName = "zwavejs/zwave-js-ui";
      imageDigest = "sha256:c43f88e2e395bb4b37c9e87e64998b751b1e1908318177623cebe08867e1eb42";
      sha256 = "";
    };
  };
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

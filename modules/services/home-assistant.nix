# SPDX-FileCopyrightText: 2023 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, ... }:

let
  images = {
    ha = {
      imageName = "homeassistant/home-assistant";
      imageDigest = "sha256:816b80788e81b517c477a200a47f3d7e882cc2b9b0504f616957a19f59518d2f";
      sha256 = "sha256-oZVAU7evGoojbX0s6yHw4ul/yKlQ4nUrn7sVBX/DOUI=";
    };
    zwave-js-ui = {
      imageName = "zwavejs/zwave-js-ui";
      imageDigest = "sha256:7fc0a78a6c843654eb93166decd13192b5a1f53637cf117ea13569f2a33a0e94";
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

# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, lib, ... }:

{
  config = {
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

    services.avahi = {
      enable = true;
      ipv6 = true;
      nssmdns = true;
      publish = {
        # wtf, realy??
        enable = true;
        userServices = true;
        addresses = true;
      };
      extraServiceFiles = {
        ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
      };
    };

    networking.networkmanager.enable = true;
    users.users.kirelagin.extraGroups = [ "networkmanager" ];

    services.xserver.enable = true;
    services.xserver.layout = "us";
    # services.xserver.xkbOptions = "eurosign:e";

    services.xserver.libinput.enable = true;

    services.xserver.desktopManager.pantheon.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.lightdm.greeters.pantheon.enable = true;
    # TODO: https://github.com/NixOS/nixpkgs/issues/100119
    users.users.lightdm.shell = pkgs.bash;

    services.thermald.enable = true;
    services.tlp.enable = true;
    services.fstrim.enable = true;
    boot.kernel.sysctl = {
      "vm.swappiness" = 1;
    };

    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
    };
  };
}
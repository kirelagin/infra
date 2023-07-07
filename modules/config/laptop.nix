# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, lib, flakes, ... }:

{
  imports = [ ./home-manager.nix ];

  config = {
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    services.throttled.extraConfig = import ./conf/throttled.nix;  # Not enabled by default
    services.thermald.enable = true;
    boot.extraModprobeConfig = ''
      options snd_hda_intel power_save=1
      options iwlwifi power_save=Y
    '';
    services.power-profiles-daemon.enable = lib.mkForce false;
    services.tlp = {
      enable = true;
    };

    services.fwupd.enable = true;

    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "suspend";
    };

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
    users.users.kirelagin.extraGroups = [ "dialout" "networkmanager" ];

    services.xserver.enable = true;
    services.xserver.layout = "us,ru";
    services.xserver.xkbOptions = "grp:win_space_toggle,misc:typo,lv3:ralt_switch";

    services.xserver.libinput.enable = true;

    services.xserver.desktopManager.pantheon.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.lightdm.greeters.pantheon.enable = true;
    programs.pantheon-tweaks.enable = true;

    services.fstrim.enable = true;
    boot.kernel.sysctl = {
      "vm.swappiness" = 1;
    };

    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      gptfdisk
      iotop
      iw
      wireguard-tools
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      powertop
    ];

    programs.adb.enable = true;

    # Allow containers to access the internet through NAT.
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
    };
    networking.firewall = {
      extraCommands = ''
        ip46tables -A FORWARD -i 've-+' -j ACCEPT
        ip46tables -A FORWARD -o 've-+' -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      '';
      extraStopCommands = ''
        ip46tables -D FORWARD -o 've-+' -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
        ip46tables -D FORWARD -i 've-+' -j ACCEPT || true
      '';
    };

  };
}

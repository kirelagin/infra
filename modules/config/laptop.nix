# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, pkgs, lib, flakes, ... }:

{
  imports = [
    ./home-device.nix
    ./home-manager.nix
  ];

  config = {
    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.systemd.enable = true;

    hardware.enableRedistributableFirmware = lib.mkDefault true;

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    services.throttled.extraConfig = import ./conf/throttled.nix;  # Not enabled by default
    services.thermald.enable = true;
    boot.extraModprobeConfig = ''
      options snd_hda_intel power_save=1
      options iwlwifi power_save=Y
    '';
    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.tlp.enable = lib.mkDefault false;

    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "suspend";
    };

    networking.networkmanager.enable = true;
    networking.nameservers = [];  # do not use harcoded dns
    users.users.kirelagin.extraGroups = [ "dialout" "networkmanager" ];

    security.tpm2 = {
      abrmd.enable = true;
      pkcs11.enable = true;
    };

    security.pam.services = {
      polkit-1.u2fAuth = true;
      sudo.u2fAuth = true;
    };

    services.resolved.enable = true;
    services.resolved.dnssec = "allow-downgrade";

    time.timeZone = null;
    services.automatic-timezoned.enable = true;

    services.xserver.enable = true;
    services.xserver.layout = "us,ru";
    services.xserver.xkbOptions = "grp:win_space_toggle,misc:typo,lv3:ralt_switch";

    services.xserver.libinput.enable = true;

    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    programs.ssh.enableAskPassword = true;
    programs.ssh.askPassword = "${pkgs.callPackage ../../pkgs/ssh-askpass-gnome4 {}}/bin/gnome-ssh-askpass4";

    services.fstrim.enable = true;
    boot.kernel.sysctl = {
      "vm.swappiness" = 1;
    };

    services.fwupd.enable = true;

    services.pcscd.enable = true;

    nixpkgs.overlays = [ flakes.agenix.overlays.default ];

    environment.systemPackages = with pkgs; [
      gptfdisk
      iotop
      iw
      wireguard-tools
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      powertop
      tpm2-tools
    ] ++ lib.optionals config.services.xserver.desktopManager.gnome.enable [
      pkgs.gnome-firmware
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

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      #alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.pipewire.wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
              bluez_monitor.properties = {
                      ["bluez5.enable-sbc-xq"] = true,
                      ["bluez5.enable-msbc"] = true,
                      ["bluez5.enable-hw-volume"] = true,
                      ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
              }
      '')
    ];

  };
}

# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ pkgs, lib, flakes, ... }:

{
  imports = [
    ./home-device.nix
    ./home-manager.nix
  ];

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
      settings = {
        CPU_BOOST_ON_AC = lib.mkDefault 1;
        CPU_BOOST_ON_BAT = lib.mkDefault 0;
        CPU_MAX_PERF_ON_AC = lib.mkDefault 100;
        CPU_MAX_PERF_ON_BAT = lib.mkDefault 60;
        CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkDefault "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkDefault "balance_power";
      };
    };

    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "suspend";
    };

    networking.networkmanager.enable = true;
    users.users.kirelagin.extraGroups = [ "dialout" "networkmanager" ];

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

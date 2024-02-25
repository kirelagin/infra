# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, lib, pkgs, ... }:

{
  imports = [ ./secrets.nix ];

  options = {
    flakes.nixpkgs = lib.mkOption {
      description = "The flake to use as nixpkgs";
      default = flakes.nixpkgs;
    };
  };

  config = {
    # Let 'nixos-version --json' know about the Git revision of this flake.
    system.configurationRevision = lib.mkIf (flakes.self ? rev) flakes.self.rev;

    boot.tmp.useTmpfs = true;

    time.timeZone = lib.mkDefault "UTC";

    # Set logfile size limit
    services.journald.extraConfig = "SystemMaxUse=300M";

    # Enable firewall
    networking.firewall = {
      enable = true;
      logRefusedConnections = false;
      extraCommands = ''
        ip46tables -w -P FORWARD DROP
      '';
    };

    networking.useDHCP = lib.mkDefault true;

    # Disable search domain list
    networking.search = [ "." ];

    # Use CloudFlare DNS
    networking.nameservers = lib.mkDefault [
      "1.1.1.1"
      "1.0.0.1"
    ];

    services.nscd.enableNsncd = true;  # kill nscd

    i18n.defaultLocale = "C.UTF-8";
    console.keyMap = "us";

    # Configure ssh
    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Set user account
    users.mutableUsers = false;
    secrets.secrets.user = {};
    users.users.kirelagin = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.secrets.secrets.user.path;
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICuih0mWtPl+LXqjWazMWPZ8b38MZfpVifC7/1wTUNS3AAAABHNzaDo= kirelagin"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCeIMHEm+lpvOzXZVF5kiXTnu05KWHsXf7IHEVFxuwaFuX7HJWdbkf5yvMQuEoNYIgiO8sEFQuhocTKYmspONBmpC8GZBRmAYo/FlrfHd0R8pB3xj88LY661/TqQleJYbOhQ9rgaOeZ2NGBtGQGF0oh9+ab5hTSdU/GE5PEUKhySXZzHIu72pGHe0E8QBnmU/pY9RqcZ8BjaSbmF/77GyizSumdXLSLjoi/mIGvJy9MPJEhB5C6AyZslAYQLj1UELOJ54g35OEhZVy183Ru0zRILP5Lxs+DqLsPItAC2S0GwpijMaz8FxQUqAKNmjVvYxuWrI3YReUlLnbZ5hNqrlbXplGDvG2tuOybPsvUu17UX6TOmPXGBIfo2WyUzSNgAXWQ+3smSV3CmeWgTz/ielFNnKqlnjjn51YMlrmGtyhxCZAY6a6v8Gj+ZxGpDXc+utk25iSq81yYUb/UCBTCNs0nM8m6VEcYPEiys0v0uSig3eQ1DS3H31zUDdgitCghvuZdIEkqWpBELFV1xa5VCR1Uo6I1vutWraws/tM+SkDLSs91iIragPvlIMoXfLtqnyHp/Prb4kughIoAL1d3jYtixmsDG8ye792z7LwlK0wkWbjsKD7snjmTSv4g6obzTIz/ZXKEDQ2szGJo7DHk+JCy4mTqqVkwBxBR87/glS1Yqw== disaster@kirelagin"
      ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "kirelagin@gmail.com";
    };

    nix.extraOptions = ''
      allow-import-from-derivation = true
      experimental-features = flakes nix-command
    '';
    nix.registry.nixpkgs.flake = config.flakes.nixpkgs;
    nix.settings.trusted-users = [ "kirelagin" ];

    services.resolved.dnssec = lib.mkDefault "true";

    # Use zsh
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.promptInit = "source ${flakes.prompt_kir}/prompt_kir.zsh";
    environment.pathsToLink = [ "/share/zsh" ];

    # Useful system packages
    environment.systemPackages = with pkgs; [
      dnsutils
      file
      gitAndTools.gitMinimal
      htop
      neovim
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      nftables
      pciutils
      psmisc  # pskill and co
      usbutils
    ];

    # Use neovim
    environment.variables.EDITOR = "nvim";
    environment.shellAliases.e = "$EDITOR";

    # Propagate SSH_ASKPASS to the session and force its use even if $DISPLAY is not set
    environment.sessionVariables.SSH_ASKPASS = lib.optionalString config.programs.ssh.enableAskPassword config.programs.ssh.askPassword;
    environment.sessionVariables.SSH_ASKPASS_REQUIRE = lib.optionalString config.programs.ssh.enableAskPassword "force";
  };
}

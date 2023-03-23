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

    boot.tmpOnTmpfs = true;

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

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    networking.useDHCP = false;

    # Disable search domain list
    networking.search = [ "." ];

    # Use CloudFlare DNS
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    i18n.defaultLocale = "C.UTF-8";
    console.keyMap = "us";

    # Configure ssh
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "no";
    };

    # Set user account
    users.mutableUsers = false;
    secrets.secrets.user = {};
    users.users.kirelagin = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      passwordFile = config.secrets.secrets.user.path;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZFavfDw355NQY4ak/fMySAL+y3SZaXmDXAbQcv3lwhlcvFoloxxdFSHktwuunrL5K+1+TPRgkKquwFtkEAspZnv/YozEAXhcMH5Sx4hk/hwLbJP9iwuwmSmT0dipaXRoXGwb0H3gH8EQenS59MhN9yPbXlX94m7Fe7WqTtokCDDJhsOJC2bjd+ns/1UDHrghzSzUbtYHeIdcI31lWzn5hwAeywV7+gVuoYb+BuYAVKQAr+WBehUVl2aByxguxedUiCLMW5z/J8GQAeooSdqmsUTxNNUIuVuaSUFl3VA0KrmYA+vSiA5KQtT6wzmdJOcn1i+F50iK/SKshymGfE5sF kirelagin"
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
      nftables
    ];

    # Use neovim
    environment.variables.EDITOR = "nvim";
    environment.shellAliases.e = "$EDITOR";
  };
}

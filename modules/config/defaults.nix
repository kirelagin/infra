# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ lib, pkgs, flakes, ... }:

{
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

    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";

    # Configure ssh
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      challengeResponseAuthentication = false;
      permitRootLogin = "no";
    };

    # Set user account
    users.mutableUsers = false;
    users.users.kirelagin = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      hashedPassword = import ../../credentials/user.nix;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCBylEUvR+heGGWgR5cYe3MdOp5m2+2wGwMq0F5R/TIJN4lU3+8tyk3qF/xcxFOXKgk1syGKIV0Er0yHIiFLtmxS5d8cFV2Qvp8l924ipVXEaXKjqnrLk/O1x5DQuPxduOrS4i1PxGYjz40XuC8kAUp/NNf5msagVb2Xkr10kTzCUbh70X4vuj6G4U5BxwTizm31S6WwvY9UkxSamJquPNaSTb1kRz9/HTgAjRBy1qFcG7MxuVWNGQ6oSC3v9b7uPTvj7T4Qih1m8Ya1SPkV3Cw8/ukLHnEOJwL2INmUd7YFBdbtyVoNeLp7iis35WH5yEbRNEKn/PjHUNw2W14Jld kirelagin"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCeIMHEm+lpvOzXZVF5kiXTnu05KWHsXf7IHEVFxuwaFuX7HJWdbkf5yvMQuEoNYIgiO8sEFQuhocTKYmspONBmpC8GZBRmAYo/FlrfHd0R8pB3xj88LY661/TqQleJYbOhQ9rgaOeZ2NGBtGQGF0oh9+ab5hTSdU/GE5PEUKhySXZzHIu72pGHe0E8QBnmU/pY9RqcZ8BjaSbmF/77GyizSumdXLSLjoi/mIGvJy9MPJEhB5C6AyZslAYQLj1UELOJ54g35OEhZVy183Ru0zRILP5Lxs+DqLsPItAC2S0GwpijMaz8FxQUqAKNmjVvYxuWrI3YReUlLnbZ5hNqrlbXplGDvG2tuOybPsvUu17UX6TOmPXGBIfo2WyUzSNgAXWQ+3smSV3CmeWgTz/ielFNnKqlnjjn51YMlrmGtyhxCZAY6a6v8Gj+ZxGpDXc+utk25iSq81yYUb/UCBTCNs0nM8m6VEcYPEiys0v0uSig3eQ1DS3H31zUDdgitCghvuZdIEkqWpBELFV1xa5VCR1Uo6I1vutWraws/tM+SkDLSs91iIragPvlIMoXfLtqnyHp/Prb4kughIoAL1d3jYtixmsDG8ye792z7LwlK0wkWbjsKD7snjmTSv4g6obzTIz/ZXKEDQ2szGJo7DHk+JCy4mTqqVkwBxBR87/glS1Yqw== disaster@kirelagin"
      ];
    };

    security.acme = {
      acceptTerms = true;
      email = "kirelagin@gmail.com";
    };

    # Enable flakes
    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
      experimental-features = ca-references flakes nix-command
    '';
    nix.registry.nixpkgs.flake = flakes.nixpkgs;

    # Use zsh
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.promptInit = "source ${flakes.prompt_kir}/prompt_kir.zsh";

    # Useful system packages
    environment.systemPackages = with pkgs; [
      dnsutils
      file
      htop
      neovim
    ];

    # Use neovim
    environment.variables.EDITOR = "nvim";
    environment.shellAliases.e = "$EDITOR";
  };
}

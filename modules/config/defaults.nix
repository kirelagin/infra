# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

inputs:
{ lib, pkgs, ... }:

{
  config = {
    # Pass top-level flakes to all modules
    _module.args = { flakes = inputs; };

    # The NixOS release to be compatible with for stateful data such as databases.
    system.stateVersion = "18.03";

    # Let 'nixos-version --json' know about the Git revision of this flake.
    system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;

    time.timeZone = "UTC";

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

    # Disable search domain list
    networking.search = [ "." ];

    # Use CloudFlare DNS
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC36mjD6UmNrBx8KDKNgUdAM3FJXzWzxQ0xlNMdecCR5DeETvCh9U9BR9Hi9q0AOy8UBhQHzHqd6HSQ5n0AD+r+YW7ooWvpC/LuHij64E5GGJhokhgcDOCP09IGXVvVNvi2Vvc0aj+OShJNMSe92r3hoXWL9AoA9BSEHBtX2cSVELLP2AoqoXlPWJwNGb8HeFluuD2tWt8l/lZlBTEV21g7m6rbISJhMz2flOMw/5W2Nz86QDGNzIerXZUCa3CZviItHytv36YVF1Lnf+WI9ijOs6HhsJ9Y2JZCpRGXV43aFjxHKse26fzJ7tDmJoxpv7ccBTejJh2eEKyoBcxL9+Rv kirelagin"
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
    nix.registry.nixpkgs.flake = inputs.nixpkgs;

    # Use zsh
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    # Use neovim
    environment.systemPackages = [ pkgs.neovim ];
    environment.variables.EDITOR = "nvim";
    environment.shellAliases.e = "$EDITOR";

    # Fixup nix-daemon for flakes
    systemd.services.nix-daemon.path = [ pkgs.git ];
  };
}

{ lib, pkgs, ... }:

{
  programs = {
    bat.enable = true;

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    htop.enable = true;

    jq.enable = true;

    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (pe: with pe; [
        pass-audit
        pass-update
      ]);
    };
  };

  home.packages = with pkgs; [
                    age-plugin-yubikey
                    agenix
                    android-tools
                    ctags
                    dnsutils
                    fd
                    fswatch
                    fzf
                    gopass
                    magic-wormhole
                    mypy
                    ncdu
                    nix-diff
                    nmap
                    (python3.withPackages (pp: [pp.requests]))
                    radare2
                    rage
                    rclone
                    reuse
                    ripgrep
                    rmapi
                    tldr
                    unzip
                    yubikey-manager
  ] ++ [
    (import ./tools/yubi-oath-backup.nix lib pkgs)
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    gnugrep
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    (import ./tools/envof.nix lib pkgs)
    (import ./tools/whicher.nix lib pkgs)
  ];

  home.shellAliases = {
    eofchomp = "${lib.getBin pkgs.perl}/bin/perl -pi -e 'chomp if eof'";
  };
}

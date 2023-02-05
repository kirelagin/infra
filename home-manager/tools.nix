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
                    androidenv.androidPkgs_9_0.platform-tools
                    ctags
                    dnsutils
                    fswatch
                    gopass
                    ncdu
                    nix-diff
                    nmap
                    python3
                    radare2
                    rclone
                    reuse
                    ripgrep
                    rmapi
                    tldr
                    unzip
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

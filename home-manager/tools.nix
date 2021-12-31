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
    haskellPackages.pandoc
                    python3
                    rclone
                    reuse
                    ripgrep
                    tldr
                    unzip
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    gnugrep
  ];

  home.shellAliases = {
    eofchomp = "${lib.getBin pkgs.perl}/bin/perl -pi -e 'chomp if eof'";
  };
}
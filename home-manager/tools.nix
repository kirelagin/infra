{ pkgs, ... }:

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
    haskellPackages.cabal-install
                    ctags
                    dnsutils
                    fswatch
    haskellPackages.ghcid
                    gopass
    haskellPackages.hasktags
    haskellPackages.hlint
                    ncdu
                    nix-diff
    haskellPackages.pandoc
                   (python3.withPackages (pp: with pp; [ pynvim six ]))
                    rclone
                    reuse
                    ripgrep
    haskellPackages.stack
    haskellPackages.stylish-haskell
                    tdesktop  # Telegram
                    tldr
                    unzip
  ];
}

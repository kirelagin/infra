{ config, lib, pkgs, ... }:

let
  cfg = config.haskell;

  hsPkgs = pkgs.haskellPackages;
  ghc = hsPkgs.ghcWithPackages (hp: with hp; [
    aeson
    exceptions
    hashable
    megaparsec
    MonadRandom
    lens
    mtl
    random
    regex-base
    regex-compat
    regex-posix
    text
    transformers
    unordered-containers
    vector
  ]);

in {
  options.haskell = {
    enable = lib.mkEnableOption "haskell" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      ghc
    ] ++ (with hsPkgs; [
      cabal-install
      ghcid
      hasktags
      hlint
      stack
      stylish-haskell
    ]);

    home.file = {
      ".ghc/ghci.conf".text = ''
        :set prompt "\ESC[7mλ>\ESC[m "
        :set prompt-cont " > "

        -- Avoid tight loops
        :set -fno-omit-yields

        :set -freverse-errors
        -- :set -Weverything

        :set +m
      '';

      ".haskeline".text = ''
        editMode: Vi
        maxHistorySize: Just 500
        historyDuplicates: IgnoreConsecutive
      '';
    };

    home.shellAliases = {
      ghc-core = lib.concatStringsSep " " [
        "ghc"
        "-fforce-recomp"
        "-ddump-simpl"
        "-dsuppress-idinfo"
        "-dsuppress-coercions"
        "-dsuppress-uniques"
        "-dsuppress-module-prefixes"
      ];
    };
  };
}

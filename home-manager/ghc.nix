{ pkgs, ... }:

{
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

  home.packages = [
    (pkgs.writeShellScriptBin "ghc-core" ''
      fn="$1"
      shift

      ghc "$fn" -fforce-recomp -ddump-simpl -dsuppress-idinfo -dsuppress-coercions -dsuppress-uniques -dsuppress-module-prefixes "$@"
    '')
  ];
}

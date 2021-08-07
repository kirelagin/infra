{ config, pkgs, ... }:

{
  imports = [
    (import ./ghc.nix)
    (import ./gdb.nix)
    (import ./git.nix)
    (import ./mail.nix)
    (import ./sagemath.nix)
  ];

  config = {
    xdg.enable = true;
  };
}

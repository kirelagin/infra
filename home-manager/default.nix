{ config, pkgs, ... }:

{
  imports = [
    (import ./ghc.nix)
    (import ./gdb.nix)
    (import ./gnupg.nix)
    (import ./git.nix)
    (import ./lldb.nix)
    (import ./mail.nix)
    (import ./sagemath.nix)
  ];

  config = {
    xdg.enable = true;
  };
}

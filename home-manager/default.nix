{ config, pkgs, ... }:

{
  imports = [
    (import ./gdb.nix)
    (import ./git.nix)
    (import ./mail.nix)
    (import ./sagemath.nix)
  ];

  config = {
    xdg.enable = true;
  };
}

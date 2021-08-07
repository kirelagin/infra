{ config, pkgs, ... }:

{
  imports = [
    (import ./git.nix)
    (import ./mail.nix)
    (import ./sagemath.nix)
  ];

  config = {
    xdg.enable = true;
  };
}

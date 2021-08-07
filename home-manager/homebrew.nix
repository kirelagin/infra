{ config, lib, pkgs, ... }:

let
  cfg = config.programs.homebrew;

in {
  options.programs.homebrew = {
    enable = lib.mkEnableOption "homebrew" // { default = pkgs.stdenv.isDarwin; };
  };

  config = lib.mkIf (cfg.enable) {
    home.sessionVariables.HOMEBREW_NO_AUTO_UPDATE = 1;
  };
}

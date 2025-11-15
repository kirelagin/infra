{ config, lib, pkgs, ... }:

{
  options = {
    kirelagin.pythonEnv = lib.mkOption {
    };
  };

  config = {
    kirelagin.pythonEnv = pkgs.python3.withPackages (pp: with pp; [
      flake8
      mypy

      numpy
      requests
      types-requests
    ]);

    home.packages = [
      config.kirelagin.pythonEnv
    ];
  };
}

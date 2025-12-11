# SPDX-FileCopyrightText: 2025 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ config, flakes, lib, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.unfree;
in

{
  options.unfree = {
    pkgnames = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Names of allowed unfree packages";
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.pkgnames;
  };
}

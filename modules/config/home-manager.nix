# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ flakes, ... }:

{
  imports = [ flakes.home-manager.nixosModules.home-manager ];

  config.home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    users.kirelagin = import ../../home-manager;
    sharedModules = [
      (import ../../home-manager/_modules/sagemath.nix)
    ];
  };
}

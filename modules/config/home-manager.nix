# SPDX-FileCopyrightText: 2022 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0

{ flakes, ... }:

{
  imports = [ flakes.home-manager.nixosModules.home-manager ];

  config.home-manager = {
    verbose = true;
    useGlobalPkgs = false;
    useUserPackages = true;
    users.kirelagin = import ../../home-manager;
    sharedModules = [
      ({ config, osConfig, ... }: {
        systemd.user.sessionVariables = config.home.sessionVariables;
        nixpkgs.overlays = osConfig.nixpkgs.overlays;
      })
    ];
    extraSpecialArgs ={
      inherit flakes;
    };
  };
}

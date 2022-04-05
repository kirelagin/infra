# SPDX-FileCopyrightText: 2022 Kirill Elagin <https://kir.elagin.me/>
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
      ({ config, ... }: {
        systemd.user.sessionVariables = config.home.sessionVariables;
      })
    ];
  };
}
